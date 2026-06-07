import 'dart:async';
import 'package:flutter_marketplace_template/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/places_service.dart';
//import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

/// ViewModel managing the user's list of chats.
class ChatsListViewModel extends ChangeNotifier {
  final IChatService _chatService;
  final IUserService _userService;
  final IPlacesService _placesService;

  String? _error;
  String? _userId;
  bool _isLoading = false;

  Map<String, (DateTime?, String?)> _chatIdlastReadAt = {};
  Map<String, String?> _chatIdChatParticipantName = {};
  Map<String, (DateTime?, String?)> get chatIdlastReadAt => _chatIdlastReadAt;
  Map<String, String?> get chatIdChatParticipantName =>
      _chatIdChatParticipantName;

  get isLoading => _isLoading;

  String? get error => _error;

  ChatsListViewModel(
    this._placesService,
    this._chatService,
    this._userService,
  ) {
    _loadUser();
  }

  /// Loads the current user's ID.
  void _loadUser() {
    _userId = _userService.getCurrentUserId();
  }

  /// Checks if the user ID is loaded; if not, attempts to load it.
  /// Returns true if the user ID is available, false otherwise.
  Future<bool> _checkUserId() async {
    if (_userId == null || _userId!.isEmpty) {
      _loadUser();
      if (_userId == null || _userId!.isEmpty) {
        _error = 'Nie zalogowano użytkownika';
        return false;
      }
    }
    return true;
  }

  /// Initializes the chats last read timestamps list when entering the chats list screen.
  Future<void> enterChatsList() async {
    _isLoading = true;
    notifyListeners();
    _checkUserId();

    final response = await _chatService.fetchLastReadTimestampsForUser(
      userId: _userId!,
    );

    if (response is FetchOneSuccess<Map<String, (DateTime?, String?)>>) {
      _chatIdlastReadAt = response.item;
    } else if (response is FetchOneFailure<Map<String, (DateTime?, String?)>>) {
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return;
    }

    await fetchChatsParticipantNames();

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches and stores the participant names for all chats.
  Future<void> fetchChatsParticipantNames() async {
    final chatIdToChatParticipantId = await _chatService
        .fetchChatParticipantsIdForUser(userId: _userId!);

    if (chatIdToChatParticipantId is FetchOneFailure<Map<String, String>>) {
      _error = chatIdToChatParticipantId.message;
      return;
    } else if (chatIdToChatParticipantId
        is FetchOneSuccess<Map<String, String>>) {
      final userIdToName = await _placesService.fetchPlacesNames(
        ids: chatIdToChatParticipantId.item.values.toList(),
      );

      if (userIdToName is FetchOneFailure<Map<String, String?>>) {
        _error = userIdToName.message;
        return;
      } else if (userIdToName is FetchOneSuccess<Map<String, String?>>) {
        chatIdToChatParticipantId.item.forEach((chatId, participantId) {
          final name = userIdToName.item[participantId];
          _chatIdChatParticipantName[chatId] = name;
        });
      }
    }
  }

  /// Checks and loads if needed the chat participant's name for a given chat ID.
  Future<void> checkChatName({required String chatId}) async {
    _isLoading = true;

    if (_chatIdChatParticipantName.containsKey(chatId) &&
        _chatIdChatParticipantName[chatId] != null) {
      _isLoading = false;
      return;
    }

    final participantId = await _chatService.fetchChatParticipantId(
      chatId: chatId,
      userId: _userId!,
    );

    switch (participantId) {
      case FetchOneFailure<String>():
        _error = participantId.message;
        break;
      case FetchOneSuccess<String>():
        final name = await _placesService.fetchPlaceName(
          placeId: participantId.item,
        );
        switch (name) {
          case FetchOneFailure<String?>():
            _error = name.message;
            break;
          case FetchOneSuccess<String?>():
            _chatIdChatParticipantName[chatId] = name.item;
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }

    _isLoading = false;
  }

  /// Subscribes to real-time updates for the user's chats.
  Stream<List<Chat>> subscribeChatsUpdates() {
    final chatIds = _chatIdlastReadAt.keys.toList();
    return _chatService.subscribeToChatsUpdates(chatIds);
  }

  /// Marks a chat as read by updating the last read timestamp locally.
  void markChatAsRead({
    required String chatId,
    required DateTime lastReadAt,
    String? lastReadMessageId,
  }) {
    _chatIdlastReadAt[chatId] = (lastReadAt, lastReadMessageId);
    notifyListeners();
  }
}
