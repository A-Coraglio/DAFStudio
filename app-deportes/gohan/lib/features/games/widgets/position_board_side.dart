import 'package:flutter/material.dart';

import '../data/game_player.dart';
import 'position_slot_tile.dart';

/// One side (Equipo A / B) of the detail court board: a labeled wrap of
/// slots [from]..[to]. Free slots call [onFreeSlotTap] when provided.
class PositionBoardSide extends StatelessWidget {
  const PositionBoardSide({
    super.key,
    required this.label,
    required this.from,
    required this.to,
    required this.bySlot,
    required this.myPlayerId,
    required this.onFreeSlotTap,
  });

  final String label;
  final int from;
  final int to;
  final Map<int, GamePlayer> bySlot;
  final int? myPlayerId;
  final void Function(int position)? onFreeSlotTap;

  @override
  Widget build(BuildContext context) {
    final onTapFor = onFreeSlotTap;
    return Expanded(
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
                  onTap: bySlot[pos] != null || onTapFor == null
                      ? null
                      : () => onTapFor(pos),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
