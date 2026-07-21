import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../data/game_positions.dart';
import '../providers/games_providers.dart';
import 'join_at_position.dart';
import 'move_to_position.dart';
import 'position_slot.dart';

/// Playtomic-style slot picker rendered on the feed card for racket-sized
/// games (2-4 players): home slots · "VS" · away slots. Tapping a free slot
/// joins the game right there — or, if you're already in, moves you to it.
class PositionSlotsRow extends ConsumerWidget {
  const PositionSlotsRow({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The list endpoint joins the roster into the card payload; the per-card
    // fetch only remains as a fallback for callers without it (e.g. detail
    // responses reused in cards).
    final players =
        game.players ?? ref.watch(gamePlayersProvider(game.id)).valueOrNull;
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;
    final bySlot = players == null
        ? const <int, GamePlayer>{}
        : GamePositions.bySlot(players);
    final iAmIn =
        game.isJoined == true ||
        (players?.any((p) => p.playerId == myPlayerId) ?? false);
    final open = game.status == 'open';
    final canJoin = players != null && open && !iAmIn;
    final canMove =
        players != null && (open || game.status == 'full') && iAmIn;
    final home = GamePositions.homeSlots(game.maxPlayers);

    Widget slot(int pos) => PositionSlot(
      player: bySlot[pos],
      isMine: bySlot[pos]?.playerId == myPlayerId,
      onTap: bySlot[pos] != null
          ? null
          : canJoin
          ? () => joinGameAtPosition(context, ref, game, pos)
          : canMove
          ? () => moveToPosition(context, ref, game, pos)
          : null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (var p = 0; p < home; p++) ...[
          if (p > 0) const SizedBox(width: 6),
          slot(p),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('VS', style: Theme.of(context).textTheme.labelSmall),
        ),
        for (var p = home; p < game.maxPlayers; p++) ...[
          if (p > home) const SizedBox(width: 6),
          slot(p),
        ],
      ],
    );
  }
}
