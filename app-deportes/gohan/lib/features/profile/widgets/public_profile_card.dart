import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/labels.dart';
import '../../../core/theme/app_colors.dart';
import '../../sports/providers/sports_providers.dart';
import '../data/player_profile.dart';
import '../providers/profile_providers.dart';
import 'profile_avatar.dart';

/// Read-only profile card for another player. Mirrors [ProfileCard] but uses
/// a non-editable [ProfileAvatar] and drops the owner-only actions. The
/// ranking shown is for the currently-selected sport.
class PublicProfileCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).extension<AppColors>()!.accent;
    final gradient = brandGradient(Theme.of(context).brightness);
    // Ranking for the currently-selected sport (falls back to the overall).
    final stats = ref.watch(playerStatsProvider(profile.id)).valueOrNull;
    final ranking = stats?.rankingPoints ?? profile.rankingPoints;
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    String? sportName;
    for (final s in sports) {
      if (s.id == stats?.sportId) sportName = s.name;
    }
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
            title: Text(sportName == null ? 'Ranking' : 'Ranking · $sportName'),
            trailing: Text('$ranking puntos'),
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
