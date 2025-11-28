// lib/presentation/providers/chat_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/domain/entities/chat_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../data/datasources/remote/chat_api.dart';
import '../../data/datasources/remote/api_client.dart';

// Service instances
final chatApiProvider = Provider<ChatApi>((ref) => ChatApi());

// State: Map<sessionId, List<ChatMessage>>
class ChatState {
  final Map<int, List<ChatMessage>> messagesBySession;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messagesBySession = const {},
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    Map<int, List<ChatMessage>>? messagesBySession,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messagesBySession: messagesBySession ?? this.messagesBySession,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this.ref) : super(const ChatState());

  final Ref ref;
  IO.Socket? _socket;
  int? _joinedSessionId;

  Future<void> ensureSocketConnected({required String token}) async {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      '${ApiClient.baseUrl}/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token}) // gatewaymu support ini
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
        // pastikan rejoin room yang sedang dibuka
        if (_joinedSessionId != null) {
          _socket!.emit('session.join', {'sessionId': _joinedSessionId});
        }
    });

    _socket!.onReconnect((_) {
        if (_joinedSessionId != null) {
          _socket!.emit('session.join', {'sessionId': _joinedSessionId});
        }
      });
    _socket!.onDisconnect((_) {/* disconnected */});

    // event payload: { id, sessionId, senderId, content, createdAt, senderRole?, ... }
    _socket!.on('message.new', (data) {
      if (data is Map) {
        try {
          final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
          _addMessage(msg.sessionId, msg);
        } catch (_) {
          // ignore payload mismatch
        }
      }
    });
  }

  void _addMessage(int sessionId, ChatMessage msg) {
    // pastikan list bertipe tepat
    final List<ChatMessage> current = [
      ...(state.messagesBySession[sessionId] ?? <ChatMessage>[])
    ];

    // hindari duplikat id
    if (!current.any((m) => m.id == msg.id)) {
      current.add(msg);
      current.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // update map dengan tipe aman
      final newMap =
      Map<int, List<ChatMessage>>.from(state.messagesBySession);
      newMap[sessionId] = current;

      state = state.copyWith(messagesBySession: newMap);
    }
  }

  Future<void> joinSession(int sessionId) async {
    if (_socket?.connected == true && _joinedSessionId != sessionId) {
      _socket!.emit('session.join', {'sessionId': sessionId});
      _joinedSessionId = sessionId;
    }
  }

  Future<void> leaveSession(int sessionId) async {
    if (_socket?.connected == true && _joinedSessionId == sessionId) {
      _socket!.emit('session.leave', {'sessionId': sessionId});
      _joinedSessionId = null;
    }
  }

  Future<void> loadMessages(int sessionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final api = ref.read(chatApiProvider);

      final raw = await api.fetchMessages(sessionId);
      // pastikan parsing ke List<ChatMessage>
      final List<ChatMessage> list = raw
          .cast<Map<String, dynamic>>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final newMap =
      Map<int, List<ChatMessage>>.from(state.messagesBySession);
      newMap[sessionId] = list;

      state = state.copyWith(
        isLoading: false,
        messagesBySession: newMap,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(int sessionId, String content) async {
    try {
      final api = ref.read(chatApiProvider);
      final json = await api.sendMessage(sessionId, content);
      final msg = ChatMessage.fromJson(Map<String, dynamic>.from(json));
      _addMessage(sessionId, msg);
    } catch (e) {
      // bisa tampilkan snackbar dari UI, jangan crash
    }
  }

  @override
  void dispose() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    super.dispose();
  }
}

final chatProvider =
StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier(ref));
