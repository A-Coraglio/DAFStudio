import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../providers/games_providers.dart';

/// Result line of the detail card. Besides the raw score, tells the user
/// which side they were on and how it went for them. Replicates the backend
/// team-split rule (roster ordered by join date, first half = home) so what
/// the user reads here matches the ELO / outcome of their history.
class GameResultText extends ConsumerWidget {
  const GameResultText({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = game.resultHome;
    final away = game.resultAway;
    if (home == null || away == null) return const SizedBox.shrink();

    final players = ref.watch(gamePlayersProvider(game.id)).valueOrNull;
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;
    final side = _mySide(players, myPlayerId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultado: $home - $away',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (side != null) ...[
          const SizedBox(height: 2),
          Text(
            _myOutcomeText(side, home, away),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _myOutcomeColor(context, side, home, away),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// null when the user didn't play or the roster isn't usable (unloaded,
  /// less than 2 players) — then only the plain score is shown.
  String? _mySide(List<GamePlayer>? players, int? myPlayerId) {
    if (players == null || players.length < 2 || myPlayerId == null) {
      return null;
    }
    final mid = players.length ~/ 2;
    for (var i = 0; i < players.length; i++) {
      if (players[i].playerId == myPlayerId) {
        return i < mid ? 'home' : 'away';
      }
    }
    return null;
  }

  String _myOutcomeText(String side, int home, int away) {
    final sideName = side == 'home' ? 'local' : 'visitante';
    if (home == away) return 'Jugaste de $sideName — empate';
    final won = (side == 'home') == (home > away);
    return won
        ? 'Jugaste de $sideName — ¡ganaste! 🎉'
        : 'Jugaste de $sideName — perdiste';
  }

  Color _myOutcomeColor(BuildContext context, String side, int home, int away) {
    final scheme = Theme.of(context).colorScheme;
    if (home == away) return scheme.onSurfaceVariant;
    final won = (side == 'home') == (home > away);
    return won ? scheme.primary : scheme.error;
  }
}
