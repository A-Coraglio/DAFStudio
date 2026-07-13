import 'package:flutter/material.dart';

import '../../../core/widgets/skeleton_box.dart';

/// Placeholder while the first matchmaking status poll resolves — mirrors
/// the queue form's rough shape.
class MatchmakingSkeleton extends StatelessWidget {
  const MatchmakingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonBox(width: 140, height: 24),
        SizedBox(height: 10),
        SkeletonBox(width: 260, height: 13),
        SizedBox(height: 24),
        SkeletonBox(height: 56, radius: 12),
        SizedBox(height: 20),
        SkeletonBox(height: 48, radius: 12),
        SizedBox(height: 20),
        SkeletonBox(height: 40, radius: 12),
        SizedBox(height: 20),
        SkeletonBox(height: 44, radius: 12),
      ],
    );
  }
}
