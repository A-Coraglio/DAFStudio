import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../games/data/game.dart';
import '../providers/home_providers.dart';
import 'next_game_empty_card.dart';

/// Hero card of the home: the user's next upcoming game at a glance.
/// Falls back to a "find a game" CTA when there's nothing scheduled.
class NextGameCard extends ConsumerWidget {
  const NextGameCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(nextGameProvider)
        .when(
          loading: () => const SkeletonBox(height: 110, radius: 16),
          error: (_, _) => const SizedBox.shrink(),
          data: (game) =>
              game == null ? const NextGameEmptyCard() : _Hero(game: game),
        );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppColors>()!.accent;
    final gradient = brandGradient(Theme.of(context).brightness);
    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () => context.push('/games/${game.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.event_available, size: 36, color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TU PRÓXIMO PARTIDO',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: accent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${game.sportName ?? 'Partido'} · '
                        '${game.currentPlayers}/${game.maxPlayers} jugadores',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 16, color: accent),
                          const SizedBox(width: 4),
                          Text(
                            formatSchedule(game.scheduledAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
