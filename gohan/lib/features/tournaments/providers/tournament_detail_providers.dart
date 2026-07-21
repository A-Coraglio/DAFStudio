import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tournament_model.dart';
import '../data/tournament_participant.dart';
import 'tournaments_providers.dart';

/// One tournament by id — backs the detail screen.
final tournamentDetailProvider = FutureProvider.family<Tournament, int>((
  ref,
  tournamentId,
) async {
  return ref.read(tournamentsRepositoryProvider).getById(tournamentId);
});

/// Everything a join/leave mutation staled: the detail, its roster, and the
/// lists that show the participant count.
void invalidateTournamentCaches(WidgetRef ref, int tournamentId) {
  ref.invalidate(tournamentDetailProvider(tournamentId));
  ref.invalidate(tournamentParticipantsProvider(tournamentId));
  ref.invalidate(tournamentsFetchProvider);
  ref.invalidate(recommendedTournamentsProvider);
}

/// Enrolled players of a tournament, join order. The detail screen derives
/// "am I enrolled?" from this list + the caller's own player id.
final tournamentParticipantsProvider =
    FutureProvider.family<List<TournamentParticipant>, int>((
      ref,
      tournamentId,
    ) async {
      return ref
          .read(tournamentsRepositoryProvider)
          .participants(tournamentId);
    });
