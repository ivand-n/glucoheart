class ChatSession {
  final int id;
  final String type;

  ChatSession({required this.id, required this.type});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      type: json['type'],
    );
  }
}
