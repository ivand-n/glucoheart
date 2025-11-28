// lib/data/repositories/chat_repository_impl.dart
import 'dart:async';
import '../datasources/remote/chat_api.dart';
import '../datasources/remote/chat_socket_service.dart';
import '../../utils/logger.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi api;
  final ChatSocketService socket;

  ChatRepositoryImpl({required this.api, required this.socket});

  final _controller = StreamController<ChatMessage>.broadcast();
  @override
  Stream<ChatMessage> get messageStream => _controller.stream;

  int? _connectedSessionId;

  @override
  Future<ChatSession> createOrGetSessionByRole(String role) async {
    // ✅ API sekarang mengembalikan Map session (BUKAN int)
    final json = await api.createOrGetSessionByRole(role);
    return ChatSession.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<List<ChatSession>> listSessions() async {
    // ✅ API sekarang ada listSessions() → List<dynamic>
    final raw = await api.listSessions();
    return raw
        .cast<Map<String, dynamic>>()
        .map((e) => ChatSession.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<List<ChatMessage>> fetchMessages(int sessionId) async {
    // ✅ API sekarang mengembalikan List<dynamic> (raw)
    final raw = await api.fetchMessages(sessionId);
    return raw
        .cast<Map<String, dynamic>>()
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<ChatMessage> sendMessage(int sessionId, String content) async {
    // ✅ API sekarang mengembalikan Map message (BUKAN entity)
    final json = await api.sendMessage(sessionId, content);
    final msg = ChatMessage.fromJson(Map<String, dynamic>.from(json));
    // Optimistic emit agar UI terasa realtime (sekalipun ws delay)
    _controller.add(msg);
    return msg;
  }

  @override
  Future<void> connectToSession(int sessionId) async {
    if (_connectedSessionId == sessionId && socket.isConnected) return;
    _connectedSessionId = sessionId;

    await socket.connectAndJoin(
      sessionId: sessionId,
      onMessage: (payload) {
        try {
          // socket kirim Map payload → parse ke entity
          final msg = ChatMessage.fromJson(
              Map<String, dynamic>.from(payload as Map));
          if (_connectedSessionId == msg.sessionId) {
            _controller.add(msg);
          }
        } catch (e) {
          Logger.e(
            'ChatRepository ws payload error: $payload',
            tag: 'ChatRepo',
            error: e,
          );
        }
      },
    );
  }

  @override
  Future<void> disconnectFromSession() async {
    if (_connectedSessionId != null) {
      socket.leave(_connectedSessionId!);
    }
    socket.disconnect();
    _connectedSessionId = null;
  }
}
