import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/chat.dart';
import '../data/chats_repository.dart';

final chatsRepositoryProvider = Provider<ChatsRepository>((ref) {
  return ChatsRepository(ref.read(apiClientProvider));
});

/// All chats the user can see — game-linked + general. Refreshed on
/// invalidate (after posting a message you probably want to refresh only
/// the specific chat's messagesStream, not the list).
final myChatsProvider = FutureProvider.autoDispose<List<Chat>>((ref) async {
  return ref.read(chatsRepositoryProvider).listMine();
});

/// Poll-based message stream for a chat. Polls every 3s while something is
/// watching it. Cheap because the query is id-indexed and capped to 50.
/// If the very first fetch fails the error surfaces (ErrorView with retry);
/// once there's data, transient network blips are swallowed and polling
/// continues — otherwise a single blip would kill the open conversation.
final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, int>((ref, chatId) async* {
      final repo = ref.read(chatsRepositoryProvider);
      var hasData = false;
      while (true) {
        try {
          yield await repo.listMessages(chatId);
          hasData = true;
        } catch (_) {
          if (!hasData) rethrow;
        }
        await Future.delayed(const Duration(seconds: 3));
      }
    });

/// Total unread messages, polled every 15s. Backs the Chats tab badge in the
/// bottom navigation; the always-mounted nav shell keeps it alive, so a
/// failure must never end the stream — it would kill the badge for the
/// whole session. Errors just skip the tick.
///
/// Watching the session stops the poll while logged out (before this, the
/// login screen kept hitting the backend with 401s every 15s) and restarts
/// it fresh when someone signs in.
final unreadTotalProvider = StreamProvider<int>((ref) async* {
  final session = ref.watch(sessionProvider);
  if (!session.isAuthenticated) {
    yield 0;
    return;
  }
  final repo = ref.read(chatsRepositoryProvider);
  while (true) {
    try {
      yield await repo.unreadTotal();
    } catch (_) {
      // keep polling; the badge shows the last known value (or 0)
    }
    await Future.delayed(const Duration(seconds: 15));
  }
});
