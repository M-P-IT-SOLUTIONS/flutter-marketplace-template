import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:randki/adapters/app_bar.dart';
import 'package:randki/l10n/app_localizations.dart';
import 'package:randki/models/chat.dart';
import 'package:randki/screens/chat_screen.dart';
import 'package:randki/view_models/chats_list_view_model.dart';

/// Screen of the list of chats.
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  late final ChatsListViewModel chatsListVM;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatsListVM = context.read<ChatsListViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatsListVM.enterChatsList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;
    final chatsListVM = context.watch<ChatsListViewModel>();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 244, 1),
      appBar: CustomAppBar(showTitle: true, showMenu: false, showChat: false,),
      body: StreamBuilder<List<Chat>>(
        stream: chatsListVM.subscribeChatsUpdates(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                ' ${AppLocalizations.of(context)!.chat_load_failure} ${(snapshot.error)}',
                style: TextStyle(
                  fontFamily: 'Mplus1p',
                  fontSize: 16 * textScale,
                  fontWeight: FontWeight.w300,
                  color: const Color.fromRGBO(16, 20, 94, 0.7),
                ),
              ),
            );
          }
          if (chatsListVM.isLoading || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          final chats = snapshot.data!;

          // Lista czatów
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: 12 * textScale,
              vertical: 12 * textScale,
            ),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              // if (lastMessageAt == null) return false;
              final hasUnread =
                  chat.lastMessageAt == null
                      ? false
                      : (chatsListVM.chatIdlastReadAt[chat.id] == null
                          ? true
                          : chatsListVM.chatIdlastReadAt[chat.id]!.$1 == null
                          ? true
                          : chat.lastMessageAt!.isAfter(
                            chatsListVM.chatIdlastReadAt[chat.id]!.$1!,
                          ));
              
              chatsListVM.checkChatName(chatId: chat.id);

              return _ChatTile(
                chat: chat,
                textScale: textScale,
                hasUnread: hasUnread,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            chatId: chat.id,
                            chatDeletedAt: chat.deletedAt,
                            lastReadMessageId:
                                chatsListVM.chatIdlastReadAt[chat.id]!.$2,
                            hasUnreadMessages: hasUnread,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget of a single chat in the list
class _ChatTile extends StatelessWidget {
  final Chat chat;
  final double textScale;
  final VoidCallback onTap;
  final bool hasUnread;

  const _ChatTile({
    required this.chat,
    required this.textScale,
    required this.hasUnread,
    required this.onTap,
  });

  String _formatLastMessageTime(DateTime? dateTime, BuildContext context) {
    if (dateTime == null) {
      return '';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - only hour and minute
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return AppLocalizations.of(context)!.yesterday;
    } else if (messageDate.year == today.year) {
      // This year
      return '${dateTime.day}.${dateTime.month}';
    } else {
      // Older - show date with year
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * textScale),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12 * textScale),
          child: Container(
            padding: EdgeInsets.all(12 * textScale),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.circular(12 * textScale),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(16, 20, 94, 0.05),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48 * textScale,
                  height: 48 * textScale,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(16, 20, 94, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chat_bubble,
                      size: 24 * textScale,
                      color: const Color.fromRGBO(16, 20, 94, 0.5),
                    ),
                  ),
                ),
                SizedBox(width: 12 * textScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.deletedAt != null
                            ? AppLocalizations.of(context)!.deletedChat
                            : context
                                    .read<ChatsListViewModel>()
                                    .chatIdChatParticipantName[chat.id] ??
                                chat.title ??
                                AppLocalizations.of(context)!.unknown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 16 * textScale,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.w500,
                          color:
                              hasUnread
                                  ? const Color.fromARGB(255, 241, 0, 0)
                                  : const Color.fromRGBO(16, 20, 94, 1),
                        ),
                      ),
                      SizedBox(height: 4 * textScale),
                      // Typ czatu
                      Text(
                        chat.type == 'private'
                            ? AppLocalizations.of(context)!.private_chat
                            : AppLocalizations.of(context)!.chat,
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 12 * textScale,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.w300,
                          color: const Color.fromRGBO(16, 20, 94, 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * textScale),
                // Czas ostatniej wiadomości
                Text(
                  _formatLastMessageTime(chat.lastMessageAt, context),
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 12 * textScale,
                    fontWeight: FontWeight.w300,
                    color: const Color.fromRGBO(16, 20, 94, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
