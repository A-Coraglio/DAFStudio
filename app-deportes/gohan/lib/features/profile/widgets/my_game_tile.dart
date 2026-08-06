import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/format/labels.dart';
import '../../games/data/game.dart';
import 'outcome_chip.dart';

/// One row in the personal history. Shows sport + scheduled date + final
/// score (or em-dash when unresolved) + the outcome chip. Tap → game detail.
class MyGameTile extends StatelessWidget {
  const MyGameTile({super.key, required this.game});

  final Game game;

  String _subtitle() {
    final parts = <String>[];
    if (game.sportName != null) parts.add(game.sportName!);
    parts.add(modeLabel(game.mode));
    if (game.scheduledAt != null) {
      parts.add(formatFullDate(game.scheduledAt!));
    }
    return parts.join(' · ');
  }

  String _score() {
    final home = game.resultHome;
    final away = game.resultAway;
    if (home == null || away == null) return '—';
    // Shown from the player's perspective (los tuyos - los rivales) so the
    // score reads consistently with the outcome chip: si ganaste, tu número
    // va primero y es el más alto.
    if (game.teamSide == 'away') return '$away - $home';
    return '$home - $away';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Custom row (not ListTile.trailing) so the two-line score + outcome chip
    // on the right always has room — the ListTile trailing slot clipped it.
    return InkWell(
      onTap: () => context.push('/games/${game.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    game.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_score(), style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                OutcomeChip(outcome: game.outcome ?? 'pending'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
