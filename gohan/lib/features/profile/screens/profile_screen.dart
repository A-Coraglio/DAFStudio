import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_view.dart';
import '../../sports/providers/sports_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/home_location_tile.dart';
import '../widgets/password_tile.dart';
import '../widgets/player_stats_card.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/profile_card.dart';
import '../widgets/theme_mode_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Seguro que querés salir de tu cuenta?',
      confirmLabel: 'Cerrar sesión',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await ref.read(sessionProvider.notifier).clear();
    if (context.mounted) context.go('/login');
  }

  String? _sportName(WidgetRef ref, int? sportId) {
    if (sportId == null) return null;
    return ref
        .watch(sportsListProvider)
        .maybeWhen(
          data: (sports) {
            try {
              return sports.firstWhere((s) => s.id == sportId).name;
            } on StateError {
              return null;
            }
          },
          orElse: () => null,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    // Ranking + stats are per the currently-selected sport.
    final stats = ref.watch(myStatsProvider).valueOrNull;
    final activeSportId = ref.watch(activeSportIdProvider);
    final activeSportName = _sportName(ref, activeSportId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myProfileProvider),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileCard(
              profile: profile,
              rankingPoints: stats?.rankingPoints ?? profile.rankingPoints,
              sportName: activeSportName,
            ),
            const SizedBox(height: 16),
            const PlayerStatsCard(),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Mis partidos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/my-games'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Mis clases'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/my-lessons'),
              ),
            ),
            const SizedBox(height: 8),
            const HomeLocationTile(),
            const SizedBox(height: 8),
            const PasswordTile(),
            const SizedBox(height: 16),
            const ThemeModeTile(),
          ],
        ),
      ),
    );
  }
}
