import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/error_view.dart';
import '../../sports/providers/sports_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/player_stats_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/theme_mode_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).clear();
    if (context.mounted) context.go('/login');
  }

  String? _favoriteSportName(WidgetRef ref, int? favoriteSportId) {
    if (favoriteSportId == null) return null;
    return ref.watch(sportsListProvider).maybeWhen(
      data: (sports) {
        try {
          return sports.firstWhere((s) => s.id == favoriteSportId).name;
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(myProfileProvider),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileCard(
              profile: profile,
              favoriteSportName: _favoriteSportName(ref, profile.favoriteSportId),
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
            const SizedBox(height: 16),
            const ThemeModeTile(),
          ],
        ),
      ),
    );
  }
}
