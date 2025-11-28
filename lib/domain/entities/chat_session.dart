import 'chat_message.dart';

class ChatSession {
  final int id;
  final String type; // 'one_to_one' | 'group'
  final int? userAId;
  final int? userBId;
  final int? assignedNurseId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final ChatMessage? lastMessage;

  ChatSession({
    required this.id,
    required this.type,
    this.userAId,
    this.userBId,
    this.assignedNurseId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      type: json['type'],
      userAId: json['userAId'],
      userBId: json['userBId'],
      assignedNurseId: json['assignedNurseId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt']) : null,
      lastMessage: json['lastMessage'] != null ? ChatMessage.fromJson(Map<String, dynamic>.from(json['lastMessage'])) : null,
    );
  }
}
