import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/providers/profile_providers.dart';
import '../providers/games_providers.dart';
import 'player_tile.dart';

class GamePlayersList extends ConsumerWidget {
  const GamePlayersList({super.key, required this.gameId});

  final int gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(gamePlayersProvider(gameId));
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;

    return Card(
      child: playersAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No pudimos cargar los jugadores: $err'),
        ),
        data: (players) {
          if (players.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Todavía no se anotó nadie.'),
            );
          }
          return Column(
            children: [
              for (int i = 0; i < players.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                PlayerTile(
                  player: players[i],
                  isMe: players[i].playerId == myPlayerId,
                  onTap: () =>
                      context.push('/players/${players[i].playerId}'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
