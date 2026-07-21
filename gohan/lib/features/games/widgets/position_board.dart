import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../data/game_positions.dart';
import '../providers/games_providers.dart';
import 'join_at_position.dart';
import 'move_to_position.dart';
import 'position_board_side.dart';

/// Court map shown in the game detail: both sides of the "cancha" with one
/// slot per position. Works for any roster size (pádel 2v2 up to vóley 6v6);
/// a free slot joins you there — or moves you there if you're already in.
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
    final open = game.status == 'open';
    final canJoin = open && !iAmIn;
    final canMove = (open || game.status == 'full') && iAmIn;
    final home = GamePositions.homeSlots(game.maxPlayers);
    final unpositioned = GamePositions.unpositioned(players);
    final onFreeSlotTap = canJoin
        ? (int pos) => joinGameAtPosition(context, ref, game, pos)
        : canMove
        ? (int pos) => moveToPosition(context, ref, game, pos)
        : null;

    PositionBoardSide side(String label, int from, int to) =>
        PositionBoardSide(
          label: label,
          from: from,
          to: to,
          bySlot: bySlot,
          myPlayerId: myPlayerId,
          onFreeSlotTap: onFreeSlotTap,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              canJoin
                  ? 'Elegí tu posición'
                  : canMove
                  ? 'Posiciones (tocá un lugar libre para cambiarte)'
                  : 'Posiciones',
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
