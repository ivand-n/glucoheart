import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glucoheart_flutter/utils/logger.dart';
import '../../domain/entities/discussion_room.dart';
import '../../domain/entities/discussion_message.dart';
import '../../data/datasources/remote/discussion_api_service.dart';
import '../../data/datasources/remote/discussion_socket_service.dart';
import '../../data/repositories/discussion_repository_impl.dart';

// Provider for secure storage
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// Provider for Dio + API Service with baseUrl set
final discussionApiServiceProvider = Provider<DiscussionApiService>((ref) {
  final dio = Dio();

  dio.options.baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://195.88.211.126:3001');
  // (Opsional) Timeout ringan
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 20);

  // Interceptor buat inject Bearer token dari secure storage + logging
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final storage = ref.read(secureStorageProvider);
          final token = await storage.read(key: 'auth_token');

          Logger.logHttpRequest(
            options.method,
            '${options.baseUrl}${options.path}',
            body: options.data,
            headers: options.headers,
          );

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['Accept'] = 'application/json';
            options.headers['Content-Type'] = 'application/json';
            Logger.d('Added token to request', tag: 'DioInterceptor');
          } else {
            Logger.w('No token available for request', tag: 'DioInterceptor');
          }
        } catch (e) {
          Logger.e('Error in request interceptor', tag: 'DioInterceptor', error: e);
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.logHttpResponse(
          response.statusCode ?? 0,
          '${response.requestOptions.baseUrl}${response.requestOptions.path}',
          response.data,
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.e(
          'Dio error: ${error.message}',
          tag: 'DioInterceptor',
          error: error,
          stackTrace: error.stackTrace,
        );
        return handler.next(error);
      },
    ),
  );

  return DiscussionApiService(dio);
});

final discussionSocketServiceProvider = Provider((ref) {
  return DiscussionSocketService();
});

// ===================
// Repository Provider
// ===================

final discussionRepositoryProvider = Provider((ref) {
  return DiscussionRepositoryImpl(
    apiService: ref.watch(discussionApiServiceProvider),
    socketService: ref.watch(discussionSocketServiceProvider),
  );
});

// ===================
// Rooms Provider
// ===================

final discussionRoomsProvider = FutureProvider<List<DiscussionRoom>>((ref) async {
  final repository = ref.watch(discussionRepositoryProvider);
  return await repository.listRooms();
});

// Provider for current room id
final currentRoomIdProvider = StateProvider<int?>((ref) => null);

// Provider for messages in current room
final roomMessagesProvider = FutureProvider.family<List<DiscussionMessage>, int>((ref, roomId) async {
  final repository = ref.watch(discussionRepositoryProvider);
  return await repository.fetchMessages(roomId);
});

// Provider for real-time messages stream
final messageStreamProvider = StreamProvider.family<DiscussionMessage, int>((ref, roomId) {
  final repository = ref.watch(discussionRepositoryProvider);

  // Connect to the room (dan auto-disconnect saat provider disposed)
  repository.connectToRoom(roomId);

  ref.onDispose(() {
    repository.disconnectFromRoom();
  });

  return repository.messageStream;
});

// ===================
// Message Input State
// ===================

class MessageInputState {
  final bool isSending;
  final String? error;

  MessageInputState({this.isSending = false, this.error});

  MessageInputState copyWith({bool? isSending, String? error}) {
    return MessageInputState(
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

final messageInputProvider = StateNotifierProvider<MessageInputNotifier, MessageInputState>((ref) {
  return MessageInputNotifier(ref);
});

class MessageInputNotifier extends StateNotifier<MessageInputState> {
  final Ref _ref;

  MessageInputNotifier(this._ref) : super(MessageInputState());

  Future<void> sendMessage(int roomId, String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      final repository = _ref.read(discussionRepositoryProvider);
      await repository.sendMessage(roomId, content);
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final roomUpdatesProvider = StreamProvider<RoomUpdate>((ref) {
  final repo = ref.watch(discussionRepositoryProvider);

  // connect lobby ketika ada listener
  repo.connectLobby();

  ref.onDispose(() {
    repo.disconnectLobby();
  });

  return repo.roomUpdates;
});
