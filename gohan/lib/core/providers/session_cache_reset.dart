import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chats/providers/chats_providers.dart';
import '../../features/classes/providers/classes_providers.dart';
import '../../features/games/providers/games_providers.dart';
import '../../features/home/providers/home_providers.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../features/sports/providers/sports_providers.dart';
import '../../features/tournaments/providers/tournaments_providers.dart';

/// Wipes every keep-alive provider that caches data belonging to (or scoped
/// by) the logged-in user. Without this, logging out and back in with another
/// account shows the previous user's profile, stats, feed and badges until
/// each provider happens to refetch. AutoDispose providers (chat messages,
/// matchmaking status) clean themselves up and are not listed here.
///
/// New user-scoped keep-alive provider? Add it to this list.
void resetUserScopedCaches(WidgetRef ref) {
  // Profile — own and browsed public profiles.
  ref.invalidate(myProfileProvider);
  ref.invalidate(myStatsProvider);
  ref.invalidate(myGamesProvider);
  ref.invalidate(mySportRankingProvider);
  ref.invalidate(playerProfileProvider);
  ref.invalidate(playerStatsProvider);
  ref.invalidate(playerGamesProvider);
  // Games — the feed and details carry per-user fields (is_joined, distance).
  ref.invalidate(feedGamesProvider);
  ref.invalidate(gameByIdProvider);
  ref.invalidate(gamePlayersProvider);
  // Home / recommendations — derived from the user's favorite sport & level.
  ref.invalidate(nextGameProvider);
  ref.invalidate(recommendedTournamentsProvider);
  ref.invalidate(tournamentsFetchProvider);
  ref.invalidate(recommendedClassesProvider);
  ref.invalidate(classesFetchProvider);
  // Chats badge + active sport (persisted per userId).
  ref.invalidate(unreadTotalProvider);
  ref.invalidate(activeSportIdProvider);
}
