import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../providers/chats_providers.dart';
import '../widgets/chat_panel.dart';

/// Full-screen view of a single chat — used for both general chats and
/// game-linked chats when routed to `/chats/:id`.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);
    final title = chatsAsync.maybeWhen(
      data: (chats) {
        for (final c in chats) {
          if (c.id == chatId) return c.displayTitle;
        }
        return 'Chat #$chatId';
      },
      orElse: () => 'Chat',
    );
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: chatsAsync.when(
        // Keep the panel mounted while myChatsProvider reloads (e.g. after
        // marking the chat read) instead of flashing a spinner.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myChatsProvider),
        ),
        data: (_) => ChatPanel(chatId: chatId),
      ),
    );
  }
}
