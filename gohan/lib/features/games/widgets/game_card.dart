import 'package:flutter/material.dart';

import '../data/game.dart';
import 'game_distance_text.dart';
import 'game_mode_badge.dart';
import 'game_players_pill.dart';
import 'game_schedule_text.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  final Game game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GameModeBadge(mode: game.mode),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                (game.sportName ?? 'Deporte') +
                    (game.level != null ? ' · ${game.level}' : ''),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GameScheduleText(scheduledAt: game.scheduledAt),
                  GamePlayersPill(
                    current: game.currentPlayers,
                    max: game.maxPlayers,
                  ),
                  if (game.distanceKm != null)
                    GameDistanceText(distanceKm: game.distanceKm!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
