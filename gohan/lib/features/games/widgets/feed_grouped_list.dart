import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/game.dart';
import 'game_card.dart';

const _bucketOrder = [
  'Hoy',
  'Mañana',
  'Esta semana',
  'Más adelante',
  'Sin fecha',
  'Ya jugados',
];

String _bucket(Game g, DateTime today) {
  final at = g.scheduledAt;
  if (at == null) return 'Sin fecha';
  final diff = DateTime(at.year, at.month, at.day).difference(today).inDays;
  if (diff < 0) return 'Ya jugados';
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Mañana';
  if (diff < 7) return 'Esta semana';
  return 'Más adelante';
}

/// Feed body: games grouped under day headers (Hoy / Mañana / ...). The
/// provider's order (nearest-first when located) is preserved inside each
/// group. [leading] renders above everything (e.g. the "pick a sport" hint).
class FeedGroupedList extends StatelessWidget {
  const FeedGroupedList({super.key, required this.games, this.leading});

  final List<Game> games;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groups = <String, List<Game>>{};
    for (final g in games) {
      groups.putIfAbsent(_bucket(g, today), () => []).add(g);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (leading != null) leading!,
        for (final bucket in _bucketOrder)
          if (groups.containsKey(bucket)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                bucket,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            for (final game in groups[bucket]!)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GameCard(
                  game: game,
                  onTap: () => context.push('/games/${game.id}'),
                ),
              ),
          ],
      ],
    );
  }
}
