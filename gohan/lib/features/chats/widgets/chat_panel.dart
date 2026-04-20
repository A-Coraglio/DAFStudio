import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/chats_providers.dart';
import 'message_bubble.dart';
import 'message_composer.dart';

/// The full chat UI for a single chat id — used both in the standalone
/// screen and embedded inside game detail/lobby.
class ChatPanel extends ConsumerWidget {
  const ChatPanel({super.key, required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatMessagesStreamProvider(chatId));
    final myUserId = ref.watch(myProfileProvider).maybeWhen(
          data: (p) => p.userId,
          orElse: () => null,
        );

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ErrorView(
              message: err.toString(),
              onRetry: () =>
                  ref.invalidate(chatMessagesStreamProvider(chatId)),
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
        MessageComposer(chatId: chatId),
      ],
    );
  }
}
