import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../data/matchmaking_ticket.dart';
import '../providers/matchmaking_providers.dart';
import '../widgets/lobby_panel.dart';
import '../widgets/match_found_panel.dart';
import '../widgets/queue_form.dart';
import '../widgets/waiting_panel.dart';

/// Single-screen state machine for matchmaking. Polls `/status/` every few
/// seconds and renders the panel matching the ticket's state.
class MatchmakingScreen extends ConsumerWidget {
  const MatchmakingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(matchmakingStatusStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matchmaking')),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(matchmakingStatusStreamProvider),
        ),
        data: (status) {
          final ticket = status.ticket;
          if (ticket == null || !ticket.status.isActive) {
            return const QueueForm();
          }
          return switch (ticket.status) {
            TicketStatus.waiting => WaitingPanel(
                ticket: ticket,
                estimatedWaitSeconds: status.estimatedWaitSeconds,
                queueDepth: status.queueDepth,
              ),
            TicketStatus.proposed || TicketStatus.accepted =>
              MatchFoundPanel(ticket: ticket, game: status.proposedGame),
            TicketStatus.matched => status.proposedGame == null
                ? const Center(child: CircularProgressIndicator())
                : LobbyPanel(game: status.proposedGame!),
            _ => const QueueForm(),
          };
        },
      ),
    );
  }
}
