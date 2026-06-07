import 'dart:async';
import 'package:flutter_marketplace_template/functions.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter_marketplace_template/models/message.dart';
import 'package:flutter_marketplace_template/models/message_reply.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

/// Service for managing chats and messages.
abstract class IChatService {
  Future<FetchResponse<String>> getOrCreateChat({
    required String receiverId,
    required String placeName,
  });
  Future<FetchResponse<DateTime?>> getChatDeletedAt({required String chatId});
  Future<void> setChatLastMessageAt({
    required String chatId,
    required DateTime timestamp,
  });
  Future<void> setLastReadMessageAt({
    required String chatId,
    required String userId,
    required String lastMessageId,
    required DateTime timestamp,
  });
  Future<FetchResponse<Message>> sendMessage({
    required String senderId,
    required String chatId,
    required String text,
    String? replyTo,
  });
  Future<FetchResponse<Map<String, (DateTime?, String?)>>>
  fetchLastReadTimestampsForUser({required String userId});
  Future<FetchResponse<String>> fetchChatParticipantId({
    required String chatId,
    required String userId,
  });
  Future<FetchResponse<Map<String, String>>> fetchChatParticipantsIdForUser({
    required String userId,
  });
  Stream<List<Message>> subscribeMessagesForChat({
    required String userId,
    required String chatId,
  });
  Stream<List<Chat>> subscribeToChatsUpdates(List<String> chatIds);
  Future<void> deleteUserChats(String userId);
}

/// Service for managing chats and messages via Supabase.
class ChatServiceSupabase implements IChatService {
  final IUserService _userService;
  static const String chats = 'chats';
  static const String chatParticipants = 'chat_participants';
  static const String messages = 'messages';

  ChatServiceSupabase(this._userService);

  /// Creates a new chat between two users and returns the chat ID.
  static Future<FetchResponse<String>> _createChat({
    required String userId,
    required String receiverId,
    required String placeName,
  }) async {
    try {
      final response =
          await supabase
              .from(chats)
              .insert({'type': 'private', 'title': ''})
              .select('id')
              .single();

      final chatId = response['id'] as String;

      // Adds members to chat_participants
      await supabase.from(chatParticipants).insert([
        {
          'chat_id': chatId,
          'user_id': userId,
          'role': 'member',
          'joined_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'chat_id': chatId,
          'user_id': receiverId,
          'role': 'member',
          'joined_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
      ]);

      return FetchOneSuccess(chatId);
    } catch (e) {
      print('Error creating chat: $e');
      return FetchOneFailure('Error creating chat: $e');
    }
  }

  /// Retrieves an existing chat ID between two users or creates a new one.
  @override
  Future<FetchResponse<String>> getOrCreateChat({
    required String receiverId,
    required String placeName,
  }) async {
    try {
      final userId = _userService.getCurrentUserId();
      if (userId == null) {
        return FetchOneFailure('No logged user');
      }
      if (userId.isEmpty) {
        return FetchOneFailure('No logged user');
      }
      //TODO: change, if the places cannot be users
      final response = await retry(
        () => supabase.rpc(
          'get_chat_for_users',
          params: {'user_a': userId, 'user_b': receiverId},
        ),
      );

      if (!(response == null || response.isEmpty)) {
        return FetchOneSuccess(response as String);
      } else {
        final chatId = await _createChat(
          userId: userId,
          receiverId: receiverId,
          placeName: placeName,
        );
        return chatId;
      }
    } catch (e) {
      print('Error getting or creating chat: $e');
      return FetchOneFailure('Error getting or creating chat: $e');
    }
  }

  /// Retrieves the deletion timestamp of a chat.
  @override
  Future<FetchResponse<DateTime?>> getChatDeletedAt({
    required String chatId,
  }) async {
    try {
      final response = await retry(
        () =>
            supabase
                .from(chats)
                .select('deleted_at')
                .eq('id', chatId)
                .maybeSingle(),
      );

      if (response == null) {
        return FetchOneFailure('Chat not found');
      }
      final deletedAtStr = response['deleted_at'] as String?;
      if (deletedAtStr != null) {
        return FetchOneSuccess(DateTime.parse(deletedAtStr));
      } else {
        return FetchOneSuccess(null);
      }
    } catch (e) {
      print('Error fetching chat deleted_at: $e');
      return FetchOneFailure('Error fetching chat deleted_at: $e');
    }
  }

  /// Updates the last message timestamp of a chat.
  @override
  Future<void> setChatLastMessageAt({
    required String chatId,
    required DateTime timestamp,
  }) async {
    try {
      await supabase
          .from(chats)
          .update({'last_message_at': timestamp.toIso8601String()})
          .eq('id', chatId);
    } catch (e) {
      print('Error updating chat last_message_at: $e');
    }
  }

  /// Updates the last read message timestamp for a user in a chat.
  @override
  Future<void> setLastReadMessageAt({
    required String chatId,
    required String userId,
    required String lastMessageId,
    required DateTime timestamp,
  }) async {
    try {
      await supabase
          .from(chatParticipants)
          .update({
            'last_read_at': timestamp.toIso8601String(),
            'last_read_message_id': lastMessageId,
          })
          .eq('chat_id', chatId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error updating last_read_at: $e');
    }
  }

  /// Sends a message in a chat.
  @override
  Future<FetchResponse<Message>> sendMessage({
    required String senderId,
    required String chatId,
    required String text,
    String? replyTo,
  }) async {
    final timestamp = DateTime.now();
    try {
      final response =
          await supabase
              .from(messages)
              .insert({
                'chat_id': chatId,
                'sender_id': senderId,
                'content': text,
                'type': 'text',
                'metadata': '{}',
                'created_at': timestamp.toIso8601String(),
                'reply_to': replyTo,
                //'is_read': false,
              })
              .select()
              .single();
      await setChatLastMessageAt(chatId: chatId, timestamp: timestamp);

      return FetchOneSuccess(Message.fromJson(response));
    } catch (e) {
      print('Error sending message: $e');
      return FetchOneFailure('Error sending message: $e');
    }
  }

  /// Fetches the last read timestamps for a user across all chats.
  @override
  Future<FetchResponse<Map<String, (DateTime?, String?)>>>
  fetchLastReadTimestampsForUser({required String userId}) async {
    try {
      final response = await supabase
          .from(chatParticipants)
          .select('chat_id, last_read_at, last_read_message_id')
          .eq('user_id', userId);

      final Map<String, (DateTime?, String?)> items = Map.fromEntries(
        (response as List).map((json) {
          final chatId = json['chat_id'] as String;
          final lastReadAtStr = json['last_read_at'] as String?;
          final lastReadAt =
              lastReadAtStr != null ? DateTime.parse(lastReadAtStr) : null;
          final lastReadMessageId = json['last_read_message_id'] as String?;
          return MapEntry(chatId, (lastReadAt, lastReadMessageId));
        }),
      );

      for (final item in items.entries) {
        print('Chat ${item.key}: lastReadAt=${item.value}');
      }
      return FetchOneSuccess(items);
    } catch (e) {
      print('Error fetching last read timestamps: $e');
      return FetchOneFailure('Error fetching last read timestamps: $e');
    }
  }

  /// Fetches the participant ID of a chat excluding the given [userId].
  @override
  Future<FetchResponse<String>> fetchChatParticipantId({
    required String chatId,
    required String userId,
  }) async {
    try {
      final response =
          await supabase
              .from(chatParticipants)
              .select('user_id')
              .eq('chat_id', chatId)
              .not('user_id', 'eq', userId)
              .maybeSingle();

      if (response == null) {
        return FetchOneFailure<String>("Chat participant not found");
      }
      final participantId = response['user_id'] as String;
      return FetchOneSuccess(participantId);
    } catch (e) {
      print('Error fetching chat participant ID: $e');
      return FetchOneFailure('Error fetching chat participant ID: $e');
    }
  }

  /// Fetches participant IDs for all chats of a user excluding the given [userId].
  @override
  Future<FetchResponse<Map<String, String>>> fetchChatParticipantsIdForUser({
    required String userId,
  }) async {
    try {
      final response = await supabase
          .from(chatParticipants)
          .select('chat_id, user_id')
          .not('user_id', 'eq', userId);

      final Map<String, String> items = Map.fromEntries(
        (response as List).map((json) {
          final chatId = json['chat_id'] as String;
          final participantId = json['user_id'] as String;
          return MapEntry(chatId, participantId);
        }),
      );

      return FetchOneSuccess(items);
    } catch (e) {
      print('Error fetching chat participant IDs: $e');
      return FetchOneFailure('Error fetching chat participant IDs: $e');
    }
  }

  /// Subscribes to messages for a specific chat by given [userId] and [chatId].
  @override
  Stream<List<Message>> subscribeMessagesForChat({
    required String userId,
    required String chatId,
  }) {
    return supabase
        .from(messages)
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .execute()
        .map((rows) {
          final map = {for (final r in rows) r['id'] as String: r};

          return rows.map((row) {
            final replyId = row['reply_to'];
            MessageReply? reply;

            if (replyId != null && map.containsKey(replyId)) {
              final replied = map[replyId]!;
              reply = MessageReply(
                messageId: replied['id'],
                authorId: replied['sender_id'],
                preview: replied['content'],
              );
            }

            return Message.fromJson(row, reply: reply);
          }).toList();
        });
  }

  /// Subscribes to updates for a list of chats.
  @override
  Stream<List<Chat>> subscribeToChatsUpdates(List<String> chatIds) {
    return supabase
        .from(chats)
        .stream(primaryKey: ['id'])
        .inFilter('id', chatIds)
        .execute()
        .map((rows) {
          final updatedChats = rows.map((row) => Chat.fromJson(row)).toList();

          updatedChats.sort((a, b) {
            final aTime = a.lastMessageAt ?? a.createdAt;
            final bTime = b.lastMessageAt ?? b.createdAt;

            final cmp = bTime.compareTo(aTime);
            if (cmp != 0) return cmp;

            return a.id.compareTo(b.id);
          });
          return updatedChats;
        });
  }

  /// Soft deletes all chats associated with a user.
  @override
  Future<void> deleteUserChats(String userId) async {
    try {
      final chatsList = await supabase
          .from(chatParticipants)
          .select('chat_id')
          .eq('user_id', userId);

      final chatsIds = chatsList.map((c) => c['chat_id'] as String).toList();
      if (chatsIds.isEmpty) {
        Log.info('The user does not participate in any chats.');
        return;
      }

      await supabase
          .from(chats)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .inFilter('id', chatsIds);

      Log.info('The user\'s chats have been marked as deleted (soft delete)');
    } catch (e) {
      Log.warning('Error occurred while deleting the user\'s chats: $e');
      rethrow;
    }
  }
}
