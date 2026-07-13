import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../games/data/game.dart';
import '../../games/providers/games_providers.dart';
import '../data/club.dart';
import '../data/court.dart';
import '../data/courts_repository.dart';

final courtsRepositoryProvider = Provider<CourtsRepository>((ref) {
  return CourtsRepository(ref.read(apiClientProvider));
});

/// Courts available for a specific sport (or all if sportId is null). The
/// create-game form uses this to populate the court picker.
final courtsForSportProvider = FutureProvider.family<List<Court>, int?>((
  ref,
  sportId,
) async {
  return ref.read(courtsRepositoryProvider).list(sportId: sportId);
});

/// All clubs — the court picker groups club courts by venue.
final clubsProvider = FutureProvider<List<Club>>((ref) async {
  return ref.read(courtsRepositoryProvider).listClubs();
});

/// Games already scheduled on a court within a calendar day — the picker
/// shows them as "occupied" slots. There is no booking system: this is the
/// best availability signal available (partidos ya creados en esa cancha).
final courtDayGamesProvider =
    FutureProvider.family<List<Game>, ({int courtId, DateTime day})>((
      ref,
      key,
    ) async {
      final start = DateTime(key.day.year, key.day.month, key.day.day);
      return ref
          .read(gamesRepositoryProvider)
          .list(
            courtId: key.courtId,
            scheduledAfter: start,
            scheduledBefore: start.add(const Duration(days: 1)),
          );
    });
