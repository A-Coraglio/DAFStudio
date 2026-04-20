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

/// The chat metadata for a specific game — the panel auto-creates it on
/// first access via `ensureForGame`.
final chatForGameProvider =
    FutureProvider.autoDispose.family<Chat, int>((ref, gameId) async {
  return ref.read(chatsRepositoryProvider).ensureForGame(gameId);
});

/// Poll-based message stream for a chat. Polls every 3s while something is
/// watching it. Cheap because the query is id-indexed and capped to 50.
final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, int>((ref, chatId) async* {
  final repo = ref.read(chatsRepositoryProvider);
  while (true) {
    yield await repo.listMessages(chatId);
    await Future.delayed(const Duration(seconds: 3));
  }
});
