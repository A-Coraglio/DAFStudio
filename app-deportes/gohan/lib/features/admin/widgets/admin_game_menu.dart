import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../games/data/game.dart';
import '../../games/providers/games_providers.dart';
import '../providers/admin_providers.dart';
import 'kick_player_dialog.dart';
import 'run_admin_action.dart';

/// Menú admin del detalle de un partido: cancelarlo o sacar a un jugador.
/// Invisible si no sos admin o el partido ya no admite cambios.
class AdminGameMenu extends ConsumerWidget {
  const AdminGameMenu({super.key, required this.game});

  final Game game;

  void _invalidateGame(WidgetRef ref) {
    ref.invalidate(gameByIdProvider(game.id));
    ref.invalidate(gamePlayersProvider(game.id));
    ref.invalidate(feedGamesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final active = game.status == 'open' || game.status == 'full';
    if (!isAdmin || !active) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Acciones de admin',
      icon: const Icon(Icons.shield_outlined),
      onSelected: (action) => switch (action) {
        'cancel' => runAdminAction(
            context, ref,
            title: 'Cancelar partido (admin)',
            message: '¿Cancelar "${game.name}"? Los jugadores lo van a ver '
                'como cancelado.',
            confirmLabel: 'Cancelar partido',
            op: (repo) => repo.cancelGame(game.id),
            successMsg: 'Partido cancelado',
            onDone: _invalidateGame,
          ),
        'kick' => showKickPlayerDialog(context, ref, game),
        _ => null,
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'cancel',
          child: Text('Cancelar partido (admin)'),
        ),
        PopupMenuItem(value: 'kick', child: Text('Sacar a un jugador…')),
      ],
    );
  }
}
