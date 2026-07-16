import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../data/tournament_model.dart';
import '../data/tournaments_repository.dart';

final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  return TournamentsRepository(ref.read(apiClientProvider));
});

/// Recommended tournaments for the home carousel — ranked server-side by the
/// user's favorite sport, level and (best-effort) location.
final recommendedTournamentsProvider = FutureProvider<List<Tournament>>((
  ref,
) async {
  final location = await ref.watch(currentLocationProvider.future);
  return ref
      .read(tournamentsRepositoryProvider)
      .recommended(nearLat: location?.lat, nearLon: location?.lon);
});

// --- Search screen filters ---------------------------------------------------

enum TournamentDateFilter { all, today, week, month }

class TournamentFilter {
  final String query; // name search (client-side)
  final int? sportId; // backend
  final String? level; // backend
  final TournamentDateFilter date; // client-side, on start_date

  const TournamentFilter({
    this.query = '',
    this.sportId,
    this.level,
    this.date = TournamentDateFilter.all,
  });

  TournamentFilter copyWith({
    String? query,
    int? sportId,
    String? level,
    TournamentDateFilter? date,
    bool clearSport = false,
    bool clearLevel = false,
  }) {
    return TournamentFilter(
      query: query ?? this.query,
      sportId: clearSport ? null : (sportId ?? this.sportId),
      level: clearLevel ? null : (level ?? this.level),
      date: date ?? this.date,
    );
  }
}

final tournamentFilterProvider = StateProvider<TournamentFilter>(
  (_) => const TournamentFilter(),
);

/// Backend fetch — only re-runs when the server-side filters (sport, level)
/// or location change, NOT on every keystroke of the name search.
final tournamentsFetchProvider = FutureProvider<List<Tournament>>((ref) async {
  final sportId = ref.watch(tournamentFilterProvider.select((f) => f.sportId));
  final level = ref.watch(tournamentFilterProvider.select((f) => f.level));
  final location = await ref.watch(currentLocationProvider.future);
  return ref
      .read(tournamentsRepositoryProvider)
      .list(
        status: 'upcoming',
        sportId: sportId,
        level: level,
        nearLat: location?.lat,
        nearLon: location?.lon,
      );
});

bool _matchesDate(DateTime start, TournamentDateFilter filter) {
  if (filter == TournamentDateFilter.all) return true;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (filter) {
    case TournamentDateFilter.today:
      final tomorrow = today.add(const Duration(days: 1));
      return start.isBefore(tomorrow) && !start.isBefore(today);
    case TournamentDateFilter.week:
      return start.isBefore(today.add(const Duration(days: 7))) &&
          !start.isBefore(today);
    case TournamentDateFilter.month:
      return start.isBefore(today.add(const Duration(days: 31))) &&
          !start.isBefore(today);
    case TournamentDateFilter.all:
      return true;
  }
}

/// The list the screen renders: backend result narrowed by the client-side
/// name and date filters.
final tournamentsListProvider = FutureProvider<List<Tournament>>((ref) async {
  final all = await ref.watch(tournamentsFetchProvider.future);
  final query = ref
      .watch(tournamentFilterProvider.select((f) => f.query))
      .trim()
      .toLowerCase();
  final date = ref.watch(tournamentFilterProvider.select((f) => f.date));
  return all.where((t) {
    if (query.isNotEmpty && !t.name.toLowerCase().contains(query)) return false;
    if (!_matchesDate(t.startDate, date)) return false;
    return true;
  }).toList();
});
