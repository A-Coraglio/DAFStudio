import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../games/data/game.dart';
import '../../games/widgets/game_info_card.dart';
import '../data/matchmaking_ticket.dart';
import '../providers/matchmaking_providers.dart';
import 'acceptance_countdown.dart';

/// Proposal screen — backend found a match and the ticket flipped to
/// `proposed`. After the user hits accept, the ticket becomes `accepted`
/// and we keep showing this panel (but greyed) until the group is complete.
class MatchFoundPanel extends ConsumerStatefulWidget {
  const MatchFoundPanel({
    super.key,
    required this.ticket,
    required this.game,
  });

  final MatchmakingTicket ticket;
  final Game? game;

  @override
  ConsumerState<MatchFoundPanel> createState() => _MatchFoundPanelState();
}

class _MatchFoundPanelState extends ConsumerState<MatchFoundPanel> {
  bool _loading = false;

  Future<void> _run(Future<void> Function() op) async {
    setState(() => _loading = true);
    try {
      await op();
      ref.invalidate(matchmakingStatusStreamProvider);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(matchmakingRepositoryProvider);
    final alreadyAccepted = widget.ticket.status == TicketStatus.accepted;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '¡Partido encontrado!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Center(
          child: AcceptanceCountdown(
            since: widget.ticket.proposedAt ?? widget.ticket.createdAt,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.game != null) GameInfoCard(game: widget.game!),
        const SizedBox(height: 20),
        if (alreadyAccepted)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Aceptaste. Esperando al resto del grupo...'),
            ),
          )
        else
          FilledButton.icon(
            onPressed: _loading
                ? null
                : () => _run(() => repo.accept(widget.ticket.id)),
            icon: const Icon(Icons.check),
            label: const Text('Aceptar'),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading
              ? null
              : () => _run(() => repo.reject(widget.ticket.id)),
          icon: const Icon(Icons.close),
          label: const Text('Cancelar'),
        ),
      ],
    );
  }
}
