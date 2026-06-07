import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/models/message.dart';
import 'package:flutter_marketplace_template/models/message_reply.dart';
import 'package:flutter_marketplace_template/view_models/chat_view_model.dart';
import 'package:flutter_marketplace_template/view_models/chats_list_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Screen displaying a chat with a Place.
class ChatScreen extends StatefulWidget {
  final String chatId;
  final DateTime? chatDeletedAt;
  final String? lastReadMessageId;
  final bool hasUnreadMessages;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatDeletedAt,
    this.lastReadMessageId,
    this.hasUnreadMessages = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatViewModel chatVM;
  final _messageController = TextEditingController();

  DateTime? _lastReadMessageAt;
  String? _lastReadMessageId;

  bool scrolledOnce = false;

  @override
  void initState() {
    try {
      super.initState();
      chatVM = context.read<ChatViewModel>();
      chatVM.setChatId(widget.chatId);
      chatVM.setChatDeletedAt(widget.chatDeletedAt);
    } catch (e) {
      print('Error in ChatScreen initState: $e');
    }
  }

  @override
  void dispose() {
    chatVM.exitChat();
    _messageController.dispose();
    super.dispose();
  }

  /// Save last read message time in [ChatsListViewModel] and database if needed when exiting the screen
  Future<void> _saveLastReadIfNeeded() async {
    if (_lastReadMessageAt == null) return;

    context.read<ChatsListViewModel>().markChatAsRead(
      chatId: widget.chatId,
      lastReadAt: _lastReadMessageAt!,
    );

    await chatVM.saveLastReadMessageAt(
      _lastReadMessageId!,
      _lastReadMessageAt!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (!didPop) return;
        await _saveLastReadIfNeeded();
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(242, 242, 244, 1),
        appBar: CustomAppBar(showTitle: true, showMenu: false, showChat: false),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;

    return Column(
      children: [
        StreamBuilder<List<Message>>(
          stream: chatVM.subscribeChatUpdates(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final newMessages = snapshot.data!;

              chatVM.setMessages(newMessages);

              //scroll to last read message only once
              if (!scrolledOnce) {
                if ( //!hadMessages &&
                widget.hasUnreadMessages && widget.lastReadMessageId != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    chatVM.scrollToMessageById(widget.lastReadMessageId!);
                  });
                }
                scrolledOnce = true;
              }

              if (newMessages.isNotEmpty) {
                _lastReadMessageAt = newMessages.first.createdAt;
                _lastReadMessageId = newMessages.first.id;
              }

              return Expanded(
                child: ScrollablePositionedList.builder(
                  reverse: true,
                  itemScrollController: chatVM.itemScrollController,
                  itemPositionsListener: chatVM.itemPositionsListener,
                  shrinkWrap: false,
                  itemCount: newMessages.length,
                  itemBuilder: (context, index) {
                    final message = newMessages[index];
                    final isMe = message.senderId == chatVM.userId;

                    return GestureDetector(
                      onLongPress: () => chatVM.setReply(message),
                      child: _MessageBubble(
                        message: message,
                        isMe: isMe,
                        textScale: textScale,
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
          },
        ),

        if (chatVM.chatDeletedAt != null)
          Padding(
            padding: EdgeInsets.all(16 * textScale),
            child: Text(
              AppLocalizations.of(context)!.deleted_chat_description,
              style: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w400,
                color: const Color.fromRGBO(255, 59, 48, 1),
              ),
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          // Answer preview
          Consumer<ChatViewModel>(
            builder: (context, vm, _) {
              final replyingTo = vm.replyingTo;
              if (replyingTo == null) {
                return const SizedBox.shrink();
              }

              return _ReplyPreview(
                reply: MessageReply(
                  messageId: replyingTo.id,
                  authorId: replyingTo.senderId,
                  preview: replyingTo.text,
                ),
                onCancel: vm.clearReply,
                onTap: () {
                  context.read<ChatViewModel>().scrollToMessageById(
                    replyingTo.id,
                  );
                },
              );
            },
          ),

          // Message input field
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * textScale,
              vertical: 12 * textScale,
            ),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(16, 20, 94, 0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: null,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 16 * textScale,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromRGBO(16, 20, 94, 1),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12 * textScale,
                          horizontal: 16 * textScale,
                        ),
                        hintText: 'Wpisz wiadomość...',
                        hintStyle: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w300,
                          color: const Color.fromRGBO(16, 20, 94, 0.5),
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(242, 242, 244, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24 * textScale),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) async {
                        await chatVM.sendMessage(text: _messageController.text);
                        _messageController.clear();
                        setState(() {});
                        chatVM.scrollToBottom();
                      },
                    ),
                  ),
                  SizedBox(width: 8 * textScale),
                  // Send button
                  Container(
                    width: 48 * textScale,
                    height: 48 * textScale,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(16, 20, 94, 1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        chatVM.isSending
                            ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            : IconButton(
                              icon: Icon(
                                Icons.send,
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                size: 22 * textScale,
                              ),
                              onPressed: () async {
                                await chatVM.sendMessage(
                                  text: _messageController.text,
                                );
                                _messageController.clear();
                                setState(() {});
                                chatVM.scrollToBottom();
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget of single message bubble
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final double textScale;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.textScale,
  });

  Widget _answerButton(BuildContext context, bool isMe) {
    return IconButton(
      icon: Icon(
        Icons.question_answer,
        color:
            isMe
                ? const Color.fromRGBO(16, 20, 94, 1)
                : const Color.fromRGBO(255, 255, 255, 1),
        size: 22 * textScale,
      ),
      onPressed: () async {
        context.read<ChatViewModel>().setReply(message);
        //setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * textScale),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) SizedBox(width: 8 * textScale),
          if (isMe) _answerButton(context, isMe),

          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * textScale,
                vertical: 10 * textScale,
              ),
              decoration: BoxDecoration(
                color:
                    isMe
                        ? const Color.fromRGBO(16, 20, 94, 1)
                        : const Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16 * textScale),
                  topRight: Radius.circular(16 * textScale),
                  bottomLeft:
                      isMe ? Radius.circular(16 * textScale) : Radius.zero,
                  bottomRight:
                      isMe ? Radius.zero : Radius.circular(16 * textScale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(16, 20, 94, 0.1),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.reply != null)
                    _ReplyInlinePreview(
                      reply: message.reply!,
                      isMe: isMe,
                      textScale: textScale,
                      onTap: () {
                        context.read<ChatViewModel>().scrollToMessageById(
                          message.reply!.messageId,
                        );
                      },
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w400,
                      color:
                          isMe
                              ? const Color.fromRGBO(255, 255, 255, 1)
                              : const Color.fromRGBO(16, 20, 94, 1),
                    ),
                  ),
                  SizedBox(height: 4 * textScale),
                  Text(
                    _formatTime(message.createdAt, context),
                    style: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 12 * textScale,
                      fontWeight: FontWeight.w300,
                      color:
                          isMe
                              ? const Color.fromRGBO(255, 255, 255, 0.7)
                              : const Color.fromRGBO(16, 20, 94, 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8 * textScale),
          if (!isMe) _answerButton(context, isMe),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - only hour and minute
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday - show "Yesterday" and time
      return '${AppLocalizations.of(context)!.yesterday} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Older - show date only
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }
}

/// Widget showing preview of the message being replied to
class _ReplyPreview extends StatelessWidget {
  final MessageReply reply;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  const _ReplyPreview({
    required this.reply,
    required this.onCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(width: 4, height: 48, color: Colors.blue),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
          ],
        ),
      ),
    );
  }
}

/// Widget showing inline preview of a replied message inside a message bubble
class _ReplyInlinePreview extends StatelessWidget {
  final MessageReply reply;
  final VoidCallback onTap;
  final bool isMe;
  final double textScale;

  const _ReplyInlinePreview({
    required this.reply,
    required this.onTap,
    required this.isMe,
    required this.textScale,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isMe
            ? const Color.fromRGBO(255, 255, 255, 0.15)
            : const Color.fromRGBO(16, 20, 94, 0.05);

    final textColor = isMe ? Colors.white : const Color.fromRGBO(16, 20, 94, 1);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 6 * textScale),
        padding: EdgeInsets.all(8 * textScale),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8 * textScale),
          border: Border(
            left: BorderSide(
              width: 3,
              color: isMe ? Colors.white : const Color.fromRGBO(16, 20, 94, 1),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reply.preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12 * textScale,
                color: textColor.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
