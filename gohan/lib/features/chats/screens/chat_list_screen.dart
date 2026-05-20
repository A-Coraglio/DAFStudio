import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../providers/chats_providers.dart';
import '../widgets/chat_list_empty_state.dart';
import '../widgets/chat_list_skeleton.dart';
import '../widgets/chat_list_tile.dart';

/// Standalone screen listing every chat the user can see (general + game-linked).
/// Game-linked chats still show here — tapping them lands on the same
/// `/chats/:id` route, which renders `ChatScreen`.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatsAsync.when(
        // Don't flash the skeleton when the list silently reloads after a
        // chat is marked read.
        skipLoadingOnReload: true,
        loading: () => const ChatListSkeleton(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(myChatsProvider),
        ),
        data: (chats) => chats.isEmpty
            ? const ChatListEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(myChatsProvider);
                  await ref.read(myChatsProvider.future);
                },
                child: ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => ChatListTile(
                    chat: chats[i],
                    onTap: () => context.push('/chats/${chats[i].id}'),
                  ),
                ),
              ),
      ),
    );
  }
}
