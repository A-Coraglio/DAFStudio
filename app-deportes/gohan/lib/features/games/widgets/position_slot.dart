import 'package:flutter/material.dart';

import '../../profile/widgets/profile_avatar.dart';
import '../data/game_player.dart';

/// One slot of a game: an avatar when occupied, a "+" circle when free.
/// [onTap] non-null makes a free slot selectable; occupied slots ignore it.
/// [isMine] highlights the current user's spot.
class PositionSlot extends StatelessWidget {
  const PositionSlot({
    super.key,
    required this.player,
    this.onTap,
    this.isMine = false,
    this.radius = 18,
  });

  final GamePlayer? player;
  final VoidCallback? onTap;
  final bool isMine;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = player;
    if (p != null) {
      final avatar = ProfileAvatar(
        avatarUrl: p.avatarUrl,
        initials: p.initials,
        radius: radius,
      );
      if (!isMine) return avatar;
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.primary, width: 2),
        ),
        child: avatar,
      );
    }
    final selectable = onTap != null;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectable
              ? scheme.primaryContainer.withValues(alpha: 0.4)
              : scheme.surfaceContainerHighest,
          border: Border.all(
            color: selectable ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Icon(
          Icons.add,
          size: radius,
          color: selectable ? scheme.primary : scheme.outline,
        ),
      ),
    );
  }
}
