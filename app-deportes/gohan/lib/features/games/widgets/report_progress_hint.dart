import 'package:flutter/material.dart';

import '../data/game.dart';

/// Small hint shown above the "Reportar resultado" button so participants
/// know how many of them already submitted a score. Hidden for games that
/// aren't reportable (cancelled, pending_acceptance) and for games that
/// already finalized (status == finished).
class ReportProgressHint extends StatelessWidget {
  const ReportProgressHint({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final reportable = game.status == 'open' || game.status == 'full';
    final count = game.confirmationsCount;
    final total = game.confirmationsTotal;
    if (!reportable || count == null || total == null || total == 0) {
      return const SizedBox.shrink();
    }

    final allReported = count >= total;
    final theme = Theme.of(context);
    final text = allReported
        ? 'Todos reportaron. Esperando que coincidan.'
        : '$count de $total jugadores ya reportaron';
    final icon = allReported ? Icons.hourglass_top : Icons.how_to_vote;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
