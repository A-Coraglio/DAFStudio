import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notify/web_notification.dart';
import '../../../core/widgets/error_view.dart';
import '../data/matchmaking_ticket.dart';
import '../providers/matchmaking_providers.dart';
import '../widgets/lobby_panel.dart';
import '../widgets/matchmaking_skeleton.dart';
import '../widgets/match_found_panel.dart';
import '../widgets/queue_form.dart';
import '../widgets/waiting_panel.dart';

/// Single-screen state machine for matchmaking. Polls `/status/` every few
/// seconds and renders the panel matching the ticket's state.
class MatchmakingScreen extends ConsumerWidget {
  const MatchmakingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Buzz when a proposal lands or the lobby completes — the user may not
    // be looking at the screen while queued. En web además va una
    // notificación del browser (sirve con la pestaña en segundo plano);
    // en mobile/desktop es un no-op.
    ref.listen(matchmakingStatusStreamProvider, (prev, next) {
      final p = prev?.valueOrNull?.ticket?.status;
      final n = next.valueOrNull?.ticket?.status;
      if (p == n) return;
      if (n == TicketStatus.proposed || n == TicketStatus.matched) {
        HapticFeedback.heavyImpact();
      }
      if (n == TicketStatus.proposed) {
        showWebNotification(
          '¡Partido encontrado!',
          'Tenés 10 minutos para aceptar — entrá a DAFStudio.',
        );
      }
    });

    final statusAsync = ref.watch(matchmakingStatusStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jugar ya')),
      body: statusAsync.when(
        loading: () => const MatchmakingSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
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
            TicketStatus.proposed || TicketStatus.accepted => MatchFoundPanel(
              ticket: ticket,
              game: status.proposedGame,
            ),
            TicketStatus.matched =>
              status.proposedGame == null
                  ? const _PreparingLobby()
                  : LobbyPanel(game: status.proposedGame!),
            _ => const QueueForm(),
          };
        },
      ),
    );
  }
}

/// `matched` without a resolved game yet — the next status poll fills it in.
class _PreparingLobby extends StatelessWidget {
  const _PreparingLobby();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Todos aceptaron! Armando tu partido...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
