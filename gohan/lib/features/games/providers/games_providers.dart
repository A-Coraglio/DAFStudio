import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/storage/mode_prefs.dart';
import '../../sports/providers/sports_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../data/games_repository.dart';

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.read(apiClientProvider));
});

/// User-selected mode filter for the feed. Null means "todos". Persisted to
/// SharedPreferences so the user's last choice survives restarts — a repeat
/// competitive player sets it once and keeps the filter forever.
class FeedModeFilterNotifier extends Notifier<String?> {
  @override
  String? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final value = await ModePrefs.readFeedFilter();
    if (value != null) state = value;
  }

  Future<void> set(String? value) async {
    state = value;
    await ModePrefs.writeFeedFilter(value);
  }
}

final feedModeFilterProvider =
    NotifierProvider<FeedModeFilterNotifier, String?>(
      FeedModeFilterNotifier.new,
    );

/// Date-range filter for the feed, applied server-side via
/// `scheduled_after`/`scheduled_before`. Games without a date only appear
/// under `all` (a SQL date comparison excludes NULL scheduled_at).
enum FeedDateFilter { all, today, week }

final feedDateFilterProvider = StateProvider<FeedDateFilter>(
  (_) => FeedDateFilter.all,
);

/// The games feed — reacts automatically to the active sport, the mode
/// filter and the date filter. Only shows `status == 'open'` games.
final feedGamesProvider = FutureProvider<List<Game>>((ref) async {
  final sportId = ref.watch(activeSportIdProvider);
  final mode = ref.watch(feedModeFilterProvider);
  final date = ref.watch(feedDateFilterProvider);
  final today = DateTime.now();
  final dayStart = DateTime(today.year, today.month, today.day);
  final (after, before) = switch (date) {
    FeedDateFilter.all => (null, null),
    FeedDateFilter.today => (dayStart, dayStart.add(const Duration(days: 1))),
    FeedDateFilter.week => (dayStart, dayStart.add(const Duration(days: 7))),
  };
  // Location is best-effort: when available it's passed so the feed shows
  // distances and sorts nearest-first. No radius → nothing is filtered out.
  final location = await ref.watch(currentLocationProvider.future);
  return ref
      .read(gamesRepositoryProvider)
      .list(
        sportId: sportId,
        mode: mode,
        status: 'open',
        scheduledAfter: after,
        scheduledBefore: before,
        nearLat: location?.lat,
        nearLon: location?.lon,
      );
});

/// Details for a single game, keyed by id. Invalidated after join/leave so
/// the detail screen refetches its latest count + status.
final gameByIdProvider = FutureProvider.family<Game, int>((ref, id) async {
  return ref.read(gamesRepositoryProvider).getById(id);
});

/// Enriched players list for a game. Invalidated alongside gameByIdProvider
/// on join/leave so the roster stays in sync.
final gamePlayersProvider = FutureProvider.family<List<GamePlayer>, int>((
  ref,
  id,
) async {
  return ref.read(gamesRepositoryProvider).listPlayers(id);
});
