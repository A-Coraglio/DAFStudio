import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../sports/widgets/sport_thumbnail.dart';
import '../data/game.dart';
import 'game_distance_text.dart';
import 'game_mode_badge.dart';
import 'game_players_pill.dart';
import 'game_schedule_text.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, required this.onTap});

  final Game game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miniatura del deporte (gradiente + ícono) — le da identidad
              // visual a la card, hace escaneable el feed y coincide con la
              // miniatura del selector de arriba.
              SportThumbnail(
                sportName: game.sportName,
                size: 44,
                borderRadius: AppRadius.input,
              ),
              const SizedBox(width: 12),
              Expanded(
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
                        if (game.isJoined == true) ...[
                          const _JoinedBadge(),
                          const SizedBox(width: 6),
                        ],
                        GameModeBadge(mode: game.mode),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (game.sportName ?? 'Deporte') +
                          game.levelSuffix +
                          (game.courtName != null
                              ? ' · ${game.courtName}'
                              : ''),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GameScheduleText(
                          scheduledAt: game.scheduledAt,
                          bold: true,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Small "Anotado" chip shown on feed cards for games the user is in.
class _JoinedBadge extends StatelessWidget {
  const _JoinedBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 13, color: scheme.onPrimaryContainer),
          const SizedBox(width: 3),
          Text(
            'Anotado',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
