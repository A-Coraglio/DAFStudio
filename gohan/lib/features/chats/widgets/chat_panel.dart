import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/chat.dart';
import '../providers/chats_providers.dart';
import 'message_bubble.dart';
import 'message_composer.dart';

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
  int? _lastMarkedId;

  void _maybeMarkRead(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    final topId = messages.first.id; // stream yields newest-first
    if (topId == _lastMarkedId) return;
    _lastMarkedId = topId;
    ref.read(chatsRepositoryProvider).markRead(widget.chatId).then((_) {
      if (!mounted) return;
      ref.invalidate(myChatsProvider);
      ref.invalidate(unreadTotalProvider);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.chatId));
    final myUserId = ref.watch(myProfileProvider).maybeWhen(
          data: (p) => p.userId,
          orElse: () => null,
        );
    messagesAsync.whenData(_maybeMarkRead);

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ErrorView(
              message: err.toString(),
              onRetry: () =>
                  ref.invalidate(chatMessagesStreamProvider(widget.chatId)),
            ),
            data: (messages) => messages.isEmpty
                ? const Center(child: Text('Todavía no hay mensajes.'))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => MessageBubble(
                      message: messages[i],
                      mine: messages[i].userId == myUserId,
                    ),
                  ),
          ),
        ),
        const Divider(height: 1),
        MessageComposer(chatId: widget.chatId),
      ],
    );
  }
}
