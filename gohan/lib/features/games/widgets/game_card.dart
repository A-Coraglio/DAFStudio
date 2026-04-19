import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/providers/sports_providers.dart';
import '../data/game.dart';
import 'game_mode_badge.dart';
import 'game_players_pill.dart';
import 'game_schedule_text.dart';

class GameCard extends ConsumerWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  final Game game;
  final VoidCallback onTap;

  String _sportName(WidgetRef ref) {
    return ref.watch(sportsListProvider).maybeWhen(
      data: (sports) {
        try {
          return sports.firstWhere((s) => s.id == game.sportId).name;
        } on StateError {
          return 'Deporte #${game.sportId}';
        }
      },
      orElse: () => '...',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                _sportName(ref) +
                    (game.level != null ? ' · ${game.level}' : ''),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GameScheduleText(scheduledAt: game.scheduledAt),
                  const SizedBox(width: 16),
                  GamePlayersPill(
                    current: game.currentPlayers,
                    max: game.maxPlayers,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
