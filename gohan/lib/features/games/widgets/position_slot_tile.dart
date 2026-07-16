import 'package:flutter/material.dart';

import '../data/game_player.dart';
import 'position_slot.dart';

/// A [PositionSlot] with the player's first name (or "Libre") underneath.
/// Used by the detail court board, where names keep big rosters readable.
class PositionSlotTile extends StatelessWidget {
  const PositionSlotTile({
    super.key,
    required this.player,
    this.onTap,
    this.isMine = false,
  });

  final GamePlayer? player;
  final VoidCallback? onTap;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final p = player;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          PositionSlot(player: p, radius: 22, isMine: isMine, onTap: onTap),
          const SizedBox(height: 4),
          Text(
            p == null ? 'Libre' : (p.firstName ?? p.displayName),
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
