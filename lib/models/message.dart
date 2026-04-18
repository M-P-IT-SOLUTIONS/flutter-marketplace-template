import 'package:randki/models/message_reply.dart';

/// Model of a chat message.
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String type;
  final String text;
  final String metadata;
  final String? replyTo;
  final DateTime createdAt;
  final DateTime? editedAt;
  //final bool isDeleted;
  //final bool isRead;

  final MessageReply? reply;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.text,
    required this.metadata,
    this.replyTo,
    this.reply,
    required this.createdAt,
    required this.editedAt,
    //required this.isDeleted,
    //required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json, {MessageReply? reply}) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      type: json['type'] as String,
      text: json['content'] as String,
      metadata: json['metadata'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: DateTime.tryParse(json['edited_at'] as String? ?? ''),
      replyTo: json['reply_to'] as String?,
      reply: reply,
      //isDeleted: (json['is_deleted'] as bool),
      //isRead: (json['is_read'] as bool),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'type': type,
      'content': text,
      'metadata': metadata,
      'reply_to': replyTo,
      //'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      //'is_read': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? text,
    String? chatId,
    //String? replyTo,
    //bool? isDeleted,
    DateTime? createdAt,
    //bool? isRead,
    String? type,
    String? metadata,
    DateTime? editedAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      editedAt: editedAt ?? this.editedAt,
      //replyTo: replyTo ?? this.replyTo,
      //isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      //isRead: isRead ?? this.isRead,
    );
  }
}
