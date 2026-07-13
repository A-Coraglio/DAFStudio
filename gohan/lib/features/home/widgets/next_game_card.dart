import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/skeleton_box.dart';
import '../../games/data/game.dart';
import '../../games/widgets/game_schedule_text.dart';
import '../providers/home_providers.dart';
import 'next_game_empty_card.dart';

/// Hero card of the home: the user's next upcoming game at a glance.
/// Falls back to a "find a game" CTA when there's nothing scheduled.
class NextGameCard extends ConsumerWidget {
  const NextGameCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(nextGameProvider).when(
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: InkWell(
        onTap: () => context.push('/games/${game.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.event_available, size: 36, color: scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TU PRÓXIMO PARTIDO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(alpha: .7),
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${game.sportName ?? 'Partido'} · '
                      '${game.currentPlayers}/${game.maxPlayers} jugadores',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    GameScheduleText(scheduledAt: game.scheduledAt),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
