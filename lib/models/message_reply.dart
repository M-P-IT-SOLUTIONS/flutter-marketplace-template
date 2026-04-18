/// Represents a reply to a message
class MessageReply {
  final String messageId;
  final String authorId;
  final String preview;

  const MessageReply({
    required this.messageId,
    required this.authorId,
    required this.preview,
  });

  factory MessageReply.fromJson(Map<String, dynamic> json) {
    return MessageReply(
      messageId: json['id'],
      authorId: json['sender_id'],
      preview: json['content'],
    );
  }
}
