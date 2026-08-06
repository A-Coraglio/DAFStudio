import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/tournament_model.dart';
import '../providers/tournament_detail_providers.dart';
import '../providers/tournaments_providers.dart';
import 'tournament_leave_button.dart';

/// Bottom bar of the tournament detail: inscribirse / darse de baja.
/// Hidden once the tournament started (roster frozen).
class TournamentJoinBar extends ConsumerStatefulWidget {
  const TournamentJoinBar({super.key, required this.tournament});

  final Tournament tournament;

  @override
  ConsumerState<TournamentJoinBar> createState() => _TournamentJoinBarState();
}

class _TournamentJoinBarState extends ConsumerState<TournamentJoinBar> {
  bool _busy = false;

  Future<void> _join() async {
    final id = widget.tournament.id;
    setState(() => _busy = true);
    try {
      await ref.read(tournamentsRepositoryProvider).join(id);
      invalidateTournamentCaches(ref, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Ya estás inscripto!')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    if (t.status != 'upcoming') return const SizedBox.shrink();
    final me = ref.watch(myProfileProvider).valueOrNull;
    final participants = ref
        .watch(tournamentParticipantsProvider(t.id))
        .valueOrNull;
    if (me == null || participants == null) return const SizedBox.shrink();
    final enrolled = participants.any((p) => p.playerId == me.id);
    final full = t.participantCount >= t.maxParticipants;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: enrolled
            ? TournamentLeaveButton(tournamentId: t.id)
            : PrimarySubmitButton(
                label: full ? 'Torneo completo' : 'Inscribirme',
                loading: _busy,
                onPressed: full ? null : _join,
              ),
      ),
    );
  }
}
