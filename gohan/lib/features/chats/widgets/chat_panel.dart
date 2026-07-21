import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/chat.dart';
import '../providers/chats_providers.dart';
import 'chat_history.dart';
import 'message_composer.dart';
import 'messages_skeleton.dart';

/// The full chat UI for a single chat id. Marks the chat read whenever the
/// newest visible message changes, so the unread badge clears while the user
/// is looking at the conversation.
class ChatPanel extends ConsumerStatefulWidget {
  const ChatPanel({super.key, required this.chatId});

  final int chatId;

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final _scroll = ScrollController();
  int? _lastMarkedId;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeMarkRead(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    final topId = messages.first.id; // stream yields newest-first
    if (topId == _lastMarkedId) return;
    _lastMarkedId = topId;
    ref
        .read(chatsRepositoryProvider)
        .markRead(widget.chatId)
        .then((_) {
          if (!mounted) return;
          ref.invalidate(myChatsProvider);
          ref.invalidate(unreadTotalProvider);
        })
        // Silencioso a propósito: si el mark-read falla (red), se reintenta
        // solo en el próximo mensaje visible — no vale un snackbar.
        .catchError((_) {});
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    // reverse:true → offset 0 is the newest message at the bottom.
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final myUserId = ref
        .watch(myProfileProvider)
        .maybeWhen(data: (p) => p.userId, orElse: () => null);
    messagesAsync.whenData(_maybeMarkRead);

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const MessagesSkeleton(),
            error: (err, _) => ErrorView(
              error: err,
              onRetry: () =>
                  ref.invalidate(chatMessagesStreamProvider(widget.chatId)),
            ),
            data: (messages) => messages.isEmpty
                ? const Center(child: Text('Todavía no hay mensajes.'))
                : ChatHistory(
                    chatId: widget.chatId,
                    window: messages,
                    myUserId: myUserId,
                    controller: _scroll,
                  ),
          ),
        ),
        const Divider(height: 1),
        MessageComposer(chatId: widget.chatId, onSent: _scrollToBottom),
      ],
    );
  }
}
