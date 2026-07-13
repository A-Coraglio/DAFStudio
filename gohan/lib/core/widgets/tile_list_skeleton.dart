import 'package:flutter/material.dart';

import 'skeleton_box.dart';

/// Generic list-of-tiles placeholder (avatar + two text lines). Drop-in
/// loading state for any screen that renders a ListView of ListTiles.
class TileListSkeleton extends StatelessWidget {
  const TileListSkeleton({super.key, this.rows = 8, this.shrinkWrap = false});

  final int rows;
  /// True when embedded inside another scrollable (e.g. a Card in a ListView).
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: rows,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const ListTile(
        leading: CircleAvatar(),
        title: Padding(
          padding: EdgeInsets.only(right: 90),
          child: SkeletonBox(height: 14),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(right: 150, top: 6),
          child: SkeletonBox(height: 11),
        ),
      ),
    );
  }
}
