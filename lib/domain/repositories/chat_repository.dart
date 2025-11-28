import '../entities/chat_session.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<ChatSession> createOrGetSessionByRole(String role);
  Future<List<ChatSession>> listSessions();
  Future<List<ChatMessage>> fetchMessages(int sessionId);
  Future<ChatMessage> sendMessage(int sessionId, String content);

  // websocket
  Future<void> connectToSession(int sessionId);
  Future<void> disconnectFromSession();
  Stream<ChatMessage> get messageStream;
}
