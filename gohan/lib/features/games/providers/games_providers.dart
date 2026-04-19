import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../sports/providers/sports_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../data/games_repository.dart';

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.read(apiClientProvider));
});

/// User-selected mode filter for the feed. Null means "todos".
final feedModeFilterProvider = StateProvider<String?>((ref) => null);

/// The games feed — reacts automatically to the active sport and the mode
/// filter. Only shows `status == 'open'` (joinable) games.
final feedGamesProvider = FutureProvider<List<Game>>((ref) async {
  final sportId = ref.watch(activeSportIdProvider);
  final mode = ref.watch(feedModeFilterProvider);
  return ref.read(gamesRepositoryProvider).list(
        sportId: sportId,
        mode: mode,
        status: 'open',
      );
});

/// Details for a single game, keyed by id. Invalidated after join/leave so
/// the detail screen refetches its latest count + status.
final gameByIdProvider = FutureProvider.family<Game, int>((ref, id) async {
  return ref.read(gamesRepositoryProvider).getById(id);
});

/// Enriched players list for a game. Invalidated alongside gameByIdProvider
/// on join/leave so the roster stays in sync.
final gamePlayersProvider =
    FutureProvider.family<List<GamePlayer>, int>((ref, id) async {
  return ref.read(gamesRepositoryProvider).listPlayers(id);
});
