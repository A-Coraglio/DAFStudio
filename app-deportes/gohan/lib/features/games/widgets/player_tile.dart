import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../data/game_player.dart';

/// Single-row view of a participant for the players list. When [onTap] is
/// set the row becomes a link to the player's public profile.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    this.isMe = false,
    this.onTap,
  });

  final GamePlayer player;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isMe ? scheme.primary : scheme.surfaceContainerHigh,
        foregroundColor: isMe ? scheme.onPrimary : scheme.onSurface,
        child: Text(_initials(player)),
      ),
      title: Text(
        isMe ? '${player.displayName} (vos)' : player.displayName,
        style: TextStyle(fontWeight: isMe ? FontWeight.w600 : FontWeight.w400),
      ),
      subtitle: Text(
        '${player.rankingPoints} pts'
        '${player.level != null ? ' · ${levelLabel(player.level)}' : ''}',
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }

  String _initials(GamePlayer p) {
    final f = (p.firstName ?? '').trim();
    final l = (p.lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return '?';
    final fi = f.isEmpty ? '' : f[0];
    final li = l.isEmpty ? '' : l[0];
    return (fi + li).toUpperCase();
  }
}
