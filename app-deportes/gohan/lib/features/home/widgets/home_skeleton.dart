import 'package:flutter/material.dart';

import '../../../core/widgets/skeleton_box.dart';

/// Placeholder for the whole home while the initial sports/profile load
/// resolves — mirrors header, hero, quick actions and carousel.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Row(
          children: [
            SkeletonBox(width: 48, height: 48, radius: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 150, height: 18),
                SizedBox(height: 6),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        SkeletonBox(height: 110, radius: 16),
        SizedBox(height: 20),
        SkeletonBox(height: 84, radius: 16),
        SizedBox(height: 20),
        SkeletonBox(width: 110, height: 16),
        SizedBox(height: 10),
        SkeletonBox(height: 140, radius: 16),
      ],
    );
  }
}
