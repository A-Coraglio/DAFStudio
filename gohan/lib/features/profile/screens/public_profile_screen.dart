import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../sports/providers/sports_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/my_game_tile.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/public_profile_card.dart';
import '../widgets/public_stats_card.dart';

/// Public, read-only profile of another player. Reached by tapping a player
/// in a game's roster, the discovery feed or a chat bubble (`/players/:id`).
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
    final games = ref.watch(playerGamesProvider(playerId)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          profileAsync.valueOrNull?.displayName ?? 'Perfil del jugador',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: profileAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
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
            const SizedBox(height: 16),
            PublicStatsCard(playerId: playerId),
            if (games != null && games.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Últimos partidos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < games.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      MyGameTile(game: games[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
