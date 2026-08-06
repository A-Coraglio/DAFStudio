import 'package:flutter/material.dart';

import '../../../core/widgets/skeleton_box.dart';

/// Placeholder shown while the chat list loads.
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 7,
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
