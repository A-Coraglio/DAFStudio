import 'package:flutter/material.dart';

import '../data/game.dart';
import 'game_mode_badge.dart';
import 'game_players_pill.dart';
import 'game_schedule_text.dart';
import 'game_status_chip.dart';

class GameInfoCard extends StatelessWidget {
  const GameInfoCard({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    game.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                GameStatusChip(status: game.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                GameModeBadge(mode: game.mode),
                const SizedBox(width: 8),
                Text(
                  (game.sportName ?? 'Deporte') +
                      (game.level != null ? ' · ${game.level}' : ''),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                GameScheduleText(scheduledAt: game.scheduledAt),
                const SizedBox(width: 20),
                GamePlayersPill(
                  current: game.currentPlayers,
                  max: game.maxPlayers,
                ),
              ],
            ),
            if (game.resultHome != null && game.resultAway != null) ...[
              const SizedBox(height: 14),
              Text(
                'Resultado: ${game.resultHome} - ${game.resultAway}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
