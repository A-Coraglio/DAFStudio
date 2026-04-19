import 'package:flutter/material.dart';

import '../data/game_player.dart';

/// Single-row view of a participant for the players list.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    this.isMe = false,
  });

  final GamePlayer player;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isMe ? scheme.primary : scheme.surfaceContainerHigh,
        foregroundColor: isMe ? scheme.onPrimary : scheme.onSurface,
        child: Text(_initials(player)),
      ),
      title: Text(
        isMe ? '${player.displayName} (vos)' : player.displayName,
        style: TextStyle(
          fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text('${player.rankingPoints} pts'
          '${player.level != null ? ' · ${player.level}' : ''}'),
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
