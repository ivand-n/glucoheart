import '../entities/discussion_room.dart';
import '../entities/discussion_message.dart';

abstract class DiscussionRepository {
  // Room operations
  Future<List<DiscussionRoom>> listRooms();
  Future<void> joinRoom(int roomId);
  Future<void> leaveRoom(int roomId);

  // Message operations
  Future<List<DiscussionMessage>> fetchMessages(int roomId);
  Future<DiscussionMessage> sendMessage(int roomId, String content);

  // WebSocket operations
  Future<void> connectToRoom(int roomId);
  Future<void> disconnectFromRoom();
  Stream<DiscussionMessage> get messageStream;
}