import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../data/game_positions.dart';
import '../providers/games_providers.dart';
import 'join_at_position.dart';
import 'position_slot_tile.dart';

/// Court map shown in the game detail: both sides of the "cancha" with one
/// slot per position. Works for any roster size (pádel 2v2 up to vóley 6v6);
/// a free slot is tappable to join right there. This is where big-roster
/// sports pick a spot — their feed card only shows a counter.
class PositionBoard extends ConsumerWidget {
  const PositionBoard({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players =
        ref.watch(gamePlayersProvider(game.id)).valueOrNull ??
        const <GamePlayer>[];
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;
    final bySlot = GamePositions.bySlot(players);
    final iAmIn = players.any((p) => p.playerId == myPlayerId);
    final canPick = game.status == 'open' && !iAmIn;
    final home = GamePositions.homeSlots(game.maxPlayers);
    final unpositioned = GamePositions.unpositioned(players);

    Widget side(String label, int from, int to) => Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var pos = from; pos < to; pos++)
                PositionSlotTile(
                  player: bySlot[pos],
                  isMine: bySlot[pos]?.playerId == myPlayerId,
                  onTap: canPick && bySlot[pos] == null
                      ? () => joinGameAtPosition(context, ref, game, pos)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              canPick ? 'Elegí tu posición' : 'Posiciones',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  side('Equipo A', 0, home),
                  const VerticalDivider(width: 20),
                  side('Equipo B', home, game.maxPlayers),
                ],
              ),
            ),
            if (unpositioned.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Sin posición: '
                '${unpositioned.map((p) => p.displayName).join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
