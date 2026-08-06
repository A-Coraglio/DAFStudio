import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../providers/tournament_detail_providers.dart';
import '../providers/tournaments_providers.dart';

/// "Darme de baja" action of the join bar, with confirmation.
class TournamentLeaveButton extends ConsumerStatefulWidget {
  const TournamentLeaveButton({super.key, required this.tournamentId});

  final int tournamentId;

  @override
  ConsumerState<TournamentLeaveButton> createState() =>
      _TournamentLeaveButtonState();
}

class _TournamentLeaveButtonState
    extends ConsumerState<TournamentLeaveButton> {
  bool _busy = false;

  Future<void> _leave() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Darse de baja',
      message: '¿Seguro que querés bajarte de este torneo?',
      confirmLabel: 'Darme de baja',
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(tournamentsRepositoryProvider)
          .leave(widget.tournamentId);
      invalidateTournamentCaches(ref, widget.tournamentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te bajaste del torneo')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _busy ? null : _leave,
        child: const Text('Darme de baja'),
      ),
    );
  }
}
