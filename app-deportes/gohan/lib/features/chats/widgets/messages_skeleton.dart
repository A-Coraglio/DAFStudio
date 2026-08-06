import 'package:flutter/material.dart';

import '../../../core/widgets/skeleton_box.dart';

/// Placeholder while a conversation loads — bubble-shaped boxes alternating
/// sides, bottom-anchored like the real (reversed) message list.
class MessagesSkeleton extends StatelessWidget {
  const MessagesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: const [
        _Bubble(mine: true, width: 200),
        _Bubble(mine: false, width: 240),
        _Bubble(mine: false, width: 160),
        _Bubble(mine: true, width: 220),
        _Bubble(mine: false, width: 180),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.mine, required this.width});

  final bool mine;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SkeletonBox(width: width, height: 44, radius: 14),
      ),
    );
  }
}
