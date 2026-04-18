/// Represents a chat conversation.
class Chat {
  final String id;
  final String type;
  final String? title;
  final DateTime createdAt;
  DateTime? lastMessageAt;
  DateTime? deletedAt;

  Chat({
    required this.id,
    required this.type,
    this.title,
    required this.createdAt,
    this.lastMessageAt,
    this.deletedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      lastMessageAt:
          json['last_message_at'] != null
              ? DateTime.parse(json['last_message_at'])
              : null,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
    );
  }
}
