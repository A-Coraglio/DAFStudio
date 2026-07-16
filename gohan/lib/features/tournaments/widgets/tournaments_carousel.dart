import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/skeleton_box.dart';
import '../providers/tournaments_providers.dart';
import 'tournament_card.dart';

/// Home carousel of recommended tournaments + a "Ver todos" action that opens
/// the full tournaments search screen.
class TournamentsCarousel extends ConsumerWidget {
  const TournamentsCarousel({super.key});

  static const _maxItems = 8;
  static const _cardWidth = 300.0;
  static const _stripHeight = 116.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendedTournamentsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Torneos para vos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/tournaments'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        async.when(
          loading: () => const SkeletonBox(height: _stripHeight, radius: 16),
          error: (_, _) => const _ErrorStrip(),
          data: (items) => items.isEmpty
              ? const _EmptyStrip()
              : SizedBox(
                  height: _stripHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        items.length > _maxItems ? _maxItems : items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                      width: _cardWidth,
                      child: TournamentCard(
                        tournament: items[i],
                        onTap: () => context.push('/tournaments'),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.emoji_events_outlined),
        title: Text('No hay torneos cerca todavía'),
        subtitle: Text('Probá ampliar la búsqueda desde "Ver todos"'),
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.error_outline),
        title: Text('No pudimos cargar los torneos'),
      ),
    );
  }
}
