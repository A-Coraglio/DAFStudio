import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../../../core/theme/app_colors.dart';
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
    final accent = Theme.of(context).extension<AppColors>()!.accent;
    final gradient = brandGradient(Theme.of(context).brightness);
    return Card(
      child: Column(
        children: [
          // Mismo tratamiento de "carnet" que el perfil propio.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 3),
                  ),
                  child: ProfileAvatar(
                    avatarUrl: profile.avatarUrl,
                    initials: _initials,
                    radius: 44,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Ranking'),
            trailing: Text('${profile.rankingPoints} puntos'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.signal_cellular_alt),
            title: const Text('Nivel'),
            trailing: Text(levelLabel(profile.level)),
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
