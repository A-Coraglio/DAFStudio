import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../games/data/game.dart';
import '../data/player_profile.dart';
import '../data/player_search_query.dart';
import '../data/player_stats.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiClientProvider));
});

/// The current user's player profile. Backs the profile screen and any widget
/// that shows ranking_points / level.
final myProfileProvider = FutureProvider<PlayerProfile>((ref) async {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

/// Public profile of an arbitrary player by id. Backs the `/players/:id`
/// screen reached by tapping a player in a game's roster.
final playerProfileProvider =
    FutureProvider.family<PlayerProfile, int>((ref, playerId) async {
  return ref.read(profileRepositoryProvider).getPlayer(playerId);
});

/// Public stats of an arbitrary player — public profile screen.
final playerStatsProvider =
    FutureProvider.family<PlayerStats, int>((ref, playerId) async {
  return ref.read(profileRepositoryProvider).getPlayerStats(playerId);
});

/// Public recent games of an arbitrary player — public profile screen.
final playerGamesProvider =
    FutureProvider.family<List<Game>, int>((ref, playerId) async {
  return ref.read(profileRepositoryProvider).getPlayerGames(playerId);
});

/// Discovery feed. The family key bundles all filters so identical searches
/// share the same fetch + cache entry.
final playerSearchProvider = FutureProvider.family<
    List<PlayerProfile>, PlayerSearchQuery>((ref, query) async {
  return ref.read(profileRepositoryProvider).searchPlayers(
        query: query.query,
        sportId: query.sportId,
        level: query.level,
        limit: query.limit,
      );
});

/// Calling user's game history. The `modeFilter` is "competitive", "casual"
/// or null (all). The screen invalidates this after the user reports a
/// result so the outcome flips immediately.
final myGamesProvider = FutureProvider.family<List<Game>, String?>(
  (ref, modeFilter) async {
    return ref.read(profileRepositoryProvider).getMyGames(mode: modeFilter);
  },
);

/// Aggregate W/L/D + ranking for the calling user. Re-fetched whenever the
/// game history is invalidated so the stats card stays in sync with the
/// history list.
final myStatsProvider = FutureProvider<PlayerStats>((ref) async {
  return ref.read(profileRepositoryProvider).getMyStats();
});
