import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../../sports/providers/sports_providers.dart';
import '../data/player_profile.dart';
import '../data/player_search_query.dart';
import '../providers/profile_providers.dart';
import 'player_search_tile.dart';

/// Body of the discovery screen: hooks into [playerSearchProvider] and
/// renders loading / empty / error / list states.
class PlayerSearchResults extends ConsumerWidget {
  const PlayerSearchResults({super.key, required this.query});

  final PlayerSearchQuery query;

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
    final async = ref.watch(playerSearchProvider(query));
    return async.when(
      loading: () => const TileListSkeleton(),
      error: (err, _) => ErrorView(
        error: err,
        onRetry: () => ref.invalidate(playerSearchProvider(query)),
      ),
      data: (players) {
        if (players.isEmpty) {
          return const IllustratedEmptyState(
            icon: Icons.person_search,
            title: 'No encontramos jugadores',
            body: 'Probá aflojar los filtros o buscar por otro nombre.',
          );
        }
        return ListView.separated(
          itemCount: players.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) => _tile(ref, players[i]),
        );
      },
    );
  }

  Widget _tile(WidgetRef ref, PlayerProfile p) => PlayerSearchTile(
    player: p,
    favoriteSportName: _sportName(ref, p.favoriteSportId),
  );
}
