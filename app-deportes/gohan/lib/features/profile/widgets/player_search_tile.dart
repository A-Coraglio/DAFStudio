import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/labels.dart';
import '../data/player_profile.dart';
import 'profile_avatar.dart';

/// Row in the discovery feed. Tapping opens the public profile screen.
class PlayerSearchTile extends StatelessWidget {
  const PlayerSearchTile({
    super.key,
    required this.player,
    required this.favoriteSportName,
  });

  final PlayerProfile player;
  final String? favoriteSportName;

  String get _initials {
    final f = (player.firstName ?? '').trim();
    final l = (player.lastName ?? '').trim();
    final fi = f.isEmpty ? '' : f[0];
    final li = l.isEmpty ? '' : l[0];
    final s = (fi + li).toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  String _subtitle() {
    final parts = <String>[];
    if (favoriteSportName != null) parts.add(favoriteSportName!);
    if (player.level != null) parts.add(levelLabel(player.level));
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProfileAvatar(
        avatarUrl: player.avatarUrl,
        initials: _initials,
        radius: 22,
      ),
      title: Text(player.displayName),
      subtitle: _subtitle().isEmpty ? null : Text(_subtitle()),
      // "0 pts" on every new player is noise — show points once they exist.
      trailing: player.rankingPoints <= 0
          ? null
          : Text(
              '${player.rankingPoints} pts',
              style: Theme.of(context).textTheme.labelMedium,
            ),
      onTap: () => context.push('/players/${player.id}'),
    );
  }
}
