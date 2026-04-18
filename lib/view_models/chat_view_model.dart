import 'dart:async';
import 'package:flutter/material.dart';
import 'package:randki/models/message.dart';
import 'package:randki/services/chat_service.dart';
import 'package:randki/services/fetch_response.dart';
import 'package:randki/services/user_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


/// ViewModel managing the state of chat and messages.
class ChatViewModel extends ChangeNotifier {
  final IUserService _userService;
  final IChatService _chatService;

  String? _chatId;
  DateTime? _chatDeletedAt;
  List<Message> _messages = [];
  bool _isSending = false;
  String? _error;
  String? _userId;
  Stream<List<Message>>? _chatUpdatesStream;
  Message? _replyingTo;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  List<Message> get messages => _messages;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get userId => _userId;
  Message? get replyingTo => _replyingTo;
  DateTime? get chatDeletedAt => _chatDeletedAt;

  void setChatId(String chatId) {
    _chatId = chatId;
  }

  void setChatDeletedAt(DateTime? deletedAt) {
    _chatDeletedAt = deletedAt;
  }

  void setMessages(List<Message> newMessages) {
    _messages = newMessages;
  }

  void setReply(Message message) {
    _replyingTo = message;
    notifyListeners();
  }

  void clearReply() {
    _replyingTo = null;
    notifyListeners();
  }

  /// Scrolls to the message with the given [messageId].
  void scrollToMessageById(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  /// Scrolls to the bottom of the message list.
  void scrollToBottom({bool animated = true}) {
    if (_messages.isEmpty) return;
    if (!itemScrollController.isAttached) return;

    itemScrollController.scrollTo(
      index: 0, // BO: reverse: true
      duration: animated ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.easeOut,
    );
  }

  bool get isAtBottom {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return true;

    // with reverse:true → index 0 = bottom
    return positions.any((p) => p.index == 0 && p.itemTrailingEdge >= 0.95);
  }

  ChatViewModel(this._userService, this._chatService) {
    _loadUser();
  }

  /// Loads the current user's ID.
  void _loadUser() {
    _userId = _userService.getCurrentUserId();
  }

  /// Checks if the user ID exists and loads it.
  Future<bool> _checkUserId() async {
    if (_userId == null || _userId!.isEmpty) {
      _loadUser();
      if (_userId == null || _userId!.isEmpty) {
        _error = 'User not logged in';
        return false;
      }
    }
    return true;
  }

  /// Sends a message with the given [text].
  Future<void> sendMessage({
    required String text,
  }) async {
    if (await _checkUserId() == false) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isSending = true;
    _error = null;
    notifyListeners();

    final replyToId = _replyingTo?.id;
    final message = await _chatService.sendMessage(
      senderId: _userId!,
      chatId: _chatId!,
      text: text,
      replyTo: replyToId,
    );

    if (message is FetchOneFailure<Message>) {
      _error = message.message;
    }

    _isSending = false;
    clearReply();
    notifyListeners();
  }

  /// Saves the timestamp of the last read message.
  Future<void> saveLastReadMessageAt(
    String lastMessageId,
    DateTime timestamp,
  ) async {
    if (await _checkUserId() == false) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    await _chatService.setLastReadMessageAt(
      chatId: _chatId!,
      userId: _userId!,
      lastMessageId: lastMessageId,
      timestamp: timestamp,
    );
  }

  /// Subscribes to chat updates and returns a stream of messages.
  Stream<List<Message>> subscribeChatUpdates() {
    if (_chatId == null || _chatId!.isEmpty) {
      _error = 'Chat ID not provided';
      notifyListeners();
      return Stream.value([]);
    }

    _chatUpdatesStream = _chatService.subscribeMessagesForChat(
      userId: _userId!,
      chatId: _chatId!,
    );
    return _chatUpdatesStream!;
  }

  Future<void> enterChat(String chatId) async {
    _chatId = chatId;
    _chatUpdatesStream = null;
  }

  void exitChat() {
    _chatDeletedAt = null;
    _replyingTo = null;
    _chatUpdatesStream = null;
  }
}
