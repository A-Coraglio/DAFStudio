import 'package:flutter/material.dart';

import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/tile_list_skeleton.dart';

/// Placeholder for the game detail screen — mirrors the info card + players
/// card layout so the real content swaps in without a jump.
class GameDetailSkeleton extends StatelessWidget {
  const GameDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 200, height: 20),
                SizedBox(height: 12),
                SkeletonBox(width: 140, height: 12),
                SizedBox(height: 16),
                SkeletonBox(width: 180, height: 12),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        SkeletonBox(width: 110, height: 16),
        SizedBox(height: 8),
        Card(child: TileListSkeleton(rows: 3, shrinkWrap: true)),
      ],
    );
  }
}
