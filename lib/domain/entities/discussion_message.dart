class DiscussionMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;

  // Computed property for UI
  bool get isFromCurrentUser => false; // Will be set by the repository

  DiscussionMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
    );
  }

  // Create a copy with modified properties
  DiscussionMessage copyWith({
    int? id,
    int? roomId,
    int? senderId,
    String? content,
    DateTime? createdAt,
    String? senderName,
    String? senderAvatar,
    bool? isFromCurrentUser,
  }) {
    return DiscussionMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }
}