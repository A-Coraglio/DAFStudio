import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../providers/chats_providers.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(myChatsProvider),
        ),
        data: (chats) => chats.isEmpty
            ? const Center(child: Text('Todavía no tenés chats.'))
            : ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = chats[i];
                  final title = c.isGameChat
                      ? 'Partido #${c.gameId}'
                      : (c.name ?? 'Chat #${c.id}');
                  return ListTile(
                    leading: Icon(c.isGameChat ? Icons.sports : Icons.chat),
                    title: Text(title),
                    subtitle: Text(c.isGameChat ? 'Chat del partido' : 'General'),
                    onTap: () => context.push('/chats/${c.id}'),
                  );
                },
              ),
      ),
    );
  }
}
