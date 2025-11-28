import 'package:glucoheart_flutter/domain/entities/discussion_message.dart';

class DiscussionRoom {
  final int id;
  final String topic;
  final String? description;
  final bool isPublic;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? lastMessageId;
  final DateTime? lastMessageAt;
  final DiscussionMessage? lastMessage;

  DiscussionRoom({
    required this.id,
    required this.topic,
    this.description,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory DiscussionRoom.fromJson(Map<String, dynamic> json) {
    return DiscussionRoom(
      id: json['id'],
      topic: json['topic'],
      description: json['description'],
      isPublic: json['isPublic'] ?? true,
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastMessageId: json['lastMessageId'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      lastMessage: json['lastMessage'] != null
          ? DiscussionMessage.fromJson(json['lastMessage'])
          : null,
    );
  }
}