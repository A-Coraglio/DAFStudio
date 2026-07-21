import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/tournament_detail_providers.dart';
import '../widgets/tournament_info_card.dart';
import '../widgets/tournament_join_bar.dart';
import '../widgets/tournament_participants_card.dart';

/// Detail of a tournament: info, enrolled players and the join/leave bar.
class TournamentDetailScreen extends ConsumerWidget {
  const TournamentDetailScreen({super.key, required this.tournamentId});

  final int tournamentId;

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(tournamentDetailProvider(tournamentId));
    ref.invalidate(tournamentParticipantsProvider(tournamentId));
    await ref.read(tournamentDetailProvider(tournamentId).future);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tournamentDetailProvider(tournamentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Torneo')),
      body: async.when(
        loading: () => const TileListSkeleton(rows: 4),
        error: (err, _) => ErrorView(
          error: err,
          message: 'No pudimos cargar el torneo.',
          onRetry: () => ref.invalidate(tournamentDetailProvider(tournamentId)),
        ),
        data: (tournament) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TournamentInfoCard(tournament: tournament),
              const SizedBox(height: 12),
              TournamentParticipantsCard(tournamentId: tournamentId),
            ],
          ),
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (tournament) => TournamentJoinBar(tournament: tournament),
        orElse: () => null,
      ),
    );
  }
}
