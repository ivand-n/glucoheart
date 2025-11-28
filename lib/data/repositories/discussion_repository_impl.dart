import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/discussion_message.dart';
import '../../domain/entities/discussion_room.dart';
import '../../domain/repositories/discussion_repository.dart';
import '../datasources/remote/discussion_api_service.dart';
import '../datasources/remote/discussion_socket_service.dart';
import '../../utils/logger.dart';

class RoomUpdate {
  final int roomId;
  final DiscussionMessage lastMessage;
  RoomUpdate({required this.roomId, required this.lastMessage});
}

class DiscussionRepositoryImpl implements DiscussionRepository {
  final DiscussionApiService apiService;
  final DiscussionSocketService socketService;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DiscussionRepositoryImpl({
    required this.apiService,
    required this.socketService,
  });

  // ==== Stream pesan untuk halaman ROOM CHAT ====
  final _messageController = StreamController<DiscussionMessage>.broadcast();
  @override
  Stream<DiscussionMessage> get messageStream => _messageController.stream;

  int? _connectedRoomId;

  // ==== Stream room update untuk LOBBY / LIST ====
  final _roomUpdateController = StreamController<RoomUpdate>.broadcast();
  Stream<RoomUpdate> get roomUpdates => _roomUpdateController.stream;

  static const String _socketBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://195.88.211.126:3001');

  // ===== ROOM CHAT =====
  @override
  Future<void> connectToRoom(int roomId) async {
    if (_connectedRoomId == roomId && socketService.isConnected) return;
    _connectedRoomId = roomId;

    final token = await _storage.read(key: 'auth_token') ?? '';

    socketService.connect(
      baseUrl: _socketBaseUrl,
      token: token,
      roomId: roomId,
      onMessageCreated: (json) {
        try {
          final int rId = (json['roomId'] as num).toInt();
          if (_connectedRoomId != rId) return;
          final msg = DiscussionMessage.fromJson(json);
          _messageController.add(msg);
        } catch (e) {
          Logger.e('Failed to parse incoming message: $json',
              tag: 'DiscussionRepo', error: e);
        }
      },
    );
  }

  @override
  Future<void> disconnectFromRoom() async {
    if (_connectedRoomId != null) {
      socketService.leaveRoom(_connectedRoomId!);
    }
    socketService.disconnect();
    _connectedRoomId = null;
  }

  // ===== LOBBY / LIST =====
  Future<void> connectLobby() async {
    final token = await _storage.read(key: 'auth_token') ?? '';
    socketService.connectLobby(
      baseUrl: _socketBaseUrl,
      token: token,
      onRoomUpdated: (json) {
        try {
          final roomId = (json['roomId'] as num).toInt();
          final lastMessage =
          DiscussionMessage.fromJson(Map<String, dynamic>.from(json['lastMessage']));
          _roomUpdateController.add(RoomUpdate(roomId: roomId, lastMessage: lastMessage));
        } catch (e) {
          Logger.e('Failed to parse room update: $json',
              tag: 'DiscussionRepo', error: e);
        }
      },
    );
  }

  Future<void> disconnectLobby() async {
    socketService.disconnect();
  }

  // ===== REST Operations =====
  @override
  Future<List<DiscussionRoom>> listRooms() async {
    final raw = await apiService.listRooms();
    return raw
        .cast<Map<String, dynamic>>()
        .map((j) => DiscussionRoom.fromJson(j))
        .toList();
  }

  @override
  Future<void> joinRoom(int roomId) async {}

  @override
  Future<void> leaveRoom(int roomId) async {
    if (_connectedRoomId == roomId) {
      await disconnectFromRoom();
    }
  }

  @override
  Future<List<DiscussionMessage>> fetchMessages(int roomId) async {
    final raw = await apiService.fetchMessages(roomId);
    return raw
        .cast<Map<String, dynamic>>()
        .map((j) => DiscussionMessage.fromJson(j))
        .toList();
  }

  @override
  Future<DiscussionMessage> sendMessage(int roomId, String content) async {
    final res = await apiService.sendMessage(roomId, content);
    final msg = DiscussionMessage.fromJson(res as Map<String, dynamic>);
    _messageController.add(msg); // optimistik
    return msg;
  }
}
