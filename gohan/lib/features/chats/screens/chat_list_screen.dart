import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../data/chat.dart';
import '../providers/chats_providers.dart';
import '../widgets/chat_list_empty_state.dart';
import '../widgets/chat_list_skeleton.dart';
import '../widgets/chat_list_tile.dart';

/// Standalone screen listing every chat the user can see (general + game-linked).
/// The search bar filters the already-loaded list by chat title and last
/// message — no backend round-trip.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _query = '';

  List<Chat> _filter(List<Chat> chats) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats
        .where(
          (c) =>
              c.displayTitle.toLowerCase().contains(q) ||
              (c.lastMessage?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(myChatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatsAsync.when(
        // Don't flash the skeleton when the list silently reloads after a
        // chat is marked read.
        skipLoadingOnReload: true,
        loading: () => const ChatListSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myChatsProvider),
        ),
        data: (chats) {
          if (chats.isEmpty) return const ChatListEmptyState();
          final visible = _filter(chats);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  hintText: 'Buscar',
                  leading: const Icon(Icons.search),
                  onChanged: (text) => setState(() => _query = text),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('Ningún chat coincide.'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(myChatsProvider);
                          await ref.read(myChatsProvider.future);
                        },
                        child: ListView.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, i) => ChatListTile(
                            chat: visible[i],
                            onTap: () =>
                                context.push('/chats/${visible[i].id}'),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
