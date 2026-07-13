import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../games/data/game.dart';
import '../../profile/providers/profile_providers.dart';

/// The user's next upcoming game, derived from their game history. A game
/// counts as "upcoming" while it's still joinable/full and its scheduled
/// time isn't more than an hour in the past (so an in-progress game keeps
/// showing until it's settled). Null when there's nothing ahead.
final nextGameProvider = FutureProvider<Game?>((ref) async {
  final games = await ref.watch(myGamesProvider(null).future);
  final cutoff = DateTime.now().subtract(const Duration(hours: 1));
  final upcoming = games.where((g) {
    final at = g.scheduledAt;
    if (at == null) return false;
    if (g.status != 'open' && g.status != 'full') return false;
    return at.isAfter(cutoff);
  }).toList()
    ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
  return upcoming.isEmpty ? null : upcoming.first;
});
