import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/skeleton_box.dart';
import '../../games/data/game.dart';
import '../../games/providers/games_providers.dart';
import '../../games/widgets/game_card.dart';

/// Horizontal strip of the closest open games, fed by the same provider as
/// the feed (already sorted nearest-first when location is available).
class NearbyGamesCarousel extends ConsumerWidget {
  const NearbyGamesCarousel({super.key});

  static const _maxItems = 6;
  static const _cardWidth = 280.0;
  static const _stripHeight = 140.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(feedGamesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Cerca tuyo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        gamesAsync.when(
          loading: () => const SkeletonBox(height: _stripHeight, radius: 16),
          error: (_, _) => const SizedBox.shrink(),
          data: (games) => games.isEmpty
              ? const _EmptyStrip()
              : _Strip(games: games.take(_maxItems).toList()),
        ),
      ],
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NearbyGamesCarousel._stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: NearbyGamesCarousel._cardWidth,
          child: GameCard(
            game: games[i],
            onTap: () => context.push('/games/${games[i].id}'),
          ),
        ),
      ),
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.explore_off_outlined),
        title: const Text('No hay partidos abiertos cerca'),
        subtitle: const Text('Creá el primero y esperá rivales'),
        onTap: () => context.push('/games/new'),
      ),
    );
  }
}
