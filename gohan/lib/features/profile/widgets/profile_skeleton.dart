import 'package:flutter/material.dart';

import '../../../core/widgets/skeleton_box.dart';

/// Placeholder for the profile screens (own + public) — avatar circle, name
/// line and the info/stats cards.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SkeletonBox(width: 96, height: 96, radius: 48),
                SizedBox(height: 14),
                SkeletonBox(width: 160, height: 18),
                SizedBox(height: 20),
                SkeletonBox(height: 14),
                SizedBox(height: 12),
                SkeletonBox(height: 14),
                SizedBox(height: 12),
                SkeletonBox(height: 14),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        SkeletonBox(height: 110, radius: 16),
      ],
    );
  }
}
