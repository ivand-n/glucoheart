// lib/domain/entities/chat_message.dart
class ChatMessage {
  final int id;
  final int sessionId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  /// tambahan dari backend (opsional)
  final String? senderName;   // contoh: "Budi Admin"
  final String? senderAvatar; // url avatar bila ada
  final String? senderRole;   // "ADMIN" | "SUPPORT" | "NURSE" | "USER" | null

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.senderRole,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      sessionId: json['sessionId'] is String
          ? int.parse(json['sessionId'])
          : json['sessionId'] as int,
      senderId: json['senderId'] is String
          ? int.parse(json['senderId'])
          : json['senderId'] as int,
      content: (json['content'] ?? '') as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
      senderRole: (json['senderRole'] as String?)?.toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'senderId': senderId,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    if (senderName != null) 'senderName': senderName,
    if (senderAvatar != null) 'senderAvatar': senderAvatar,
    if (senderRole != null) 'senderRole': senderRole,
  };
}
