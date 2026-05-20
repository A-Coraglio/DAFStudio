import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../sports/providers/sports_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/public_profile_card.dart';

/// Public, read-only profile of another player. Reached by tapping a player
/// in a game's roster or lobby (`/players/:id`).
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key, required this.playerId});

  final int playerId;

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
    final profileAsync = ref.watch(playerProfileProvider(playerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del jugador')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(playerProfileProvider(playerId)),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PublicProfileCard(
              profile: profile,
              favoriteSportName:
                  _favoriteSportName(ref, profile.favoriteSportId),
            ),
          ],
        ),
      ),
    );
  }
}
