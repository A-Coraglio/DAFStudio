import 'package:flutter/material.dart';

import '../data/player_profile.dart';
import 'profile_avatar.dart';

/// Read-only profile card for another player. Mirrors [ProfileCard] but uses
/// a non-editable [ProfileAvatar] and drops the owner-only actions.
class PublicProfileCard extends StatelessWidget {
  const PublicProfileCard({
    super.key,
    required this.profile,
    required this.favoriteSportName,
  });

  final PlayerProfile profile;
  final String? favoriteSportName;

  String get _initials {
    final f = (profile.firstName ?? '').trim();
    final l = (profile.lastName ?? '').trim();
    final fi = f.isEmpty ? '' : f[0];
    final li = l.isEmpty ? '' : l[0];
    final s = (fi + li).toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                ProfileAvatar(
                  avatarUrl: profile.avatarUrl,
                  initials: _initials,
                  radius: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.military_tech),
            title: const Text('Ranking'),
            trailing: Text('${profile.rankingPoints} puntos'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.signal_cellular_alt),
            title: const Text('Nivel'),
            trailing: Text(profile.level ?? 'Sin definir'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sports),
            title: const Text('Deporte favorito'),
            trailing: Text(favoriteSportName ?? 'Sin definir'),
          ),
        ],
      ),
    );
  }
}
