import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/see_more_card.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../providers/tournaments_providers.dart';
import 'tournament_card.dart';

/// Home carousel of recommended tournaments. The trailing "Ver más" card
/// opens the full tournaments search screen.
class TournamentsCarousel extends ConsumerWidget {
  const TournamentsCarousel({super.key});

  static const _maxItems = 10;
  static const _cardWidth = 300.0;
  static const _stripHeight = 116.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendedTournamentsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Torneos para vos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        async.when(
          loading: () => const SkeletonBox(height: _stripHeight, radius: 16),
          error: (_, _) => const _ErrorStrip(),
          data: (items) {
            if (items.isEmpty) return const _EmptyStrip();
            final count =
                items.length > _maxItems ? _maxItems : items.length;
            return SizedBox(
              height: _stripHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: count + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  if (i == count) {
                    return SeeMoreCard(
                      onTap: () => context.push('/tournaments'),
                    );
                  }
                  return SizedBox(
                    width: _cardWidth,
                    child: TournamentCard(
                      tournament: items[i],
                      onTap: () =>
                          context.push('/tournaments/${items[i].id}'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events_outlined),
        title: const Text('No hay torneos cerca todavía'),
        subtitle: const Text('Tocá para ampliar la búsqueda'),
        onTap: () => context.push('/tournaments'),
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
