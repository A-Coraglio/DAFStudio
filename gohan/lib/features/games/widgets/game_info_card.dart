import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/dates.dart';
import '../../../core/format/labels.dart';
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
                      (game.level != null ? ' · ${levelLabel(game.level)}' : ''),
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
            if (formatCountdown(game.scheduledAt) != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatCountdown(game.scheduledAt)!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
            if (game.courtName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      game.courtName!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (game.courtLat != null && game.courtLon != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri.parse(
                        'https://www.google.com/maps/search/?api=1'
                        '&query=${game.courtLat},${game.courtLon}',
                      )),
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Cómo llegar'),
                    ),
                ],
              ),
            ],
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
