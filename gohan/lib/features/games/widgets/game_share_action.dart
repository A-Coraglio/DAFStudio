import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/format/dates.dart';
import '../data/game.dart';

/// AppBar action that copies a ready-to-paste invite for the game. A native
/// share sheet needs share_plus + deep links; the clipboard covers web today.
class GameShareAction extends StatelessWidget {
  const GameShareAction({super.key, required this.game});

  final Game game;

  String _invite() {
    final spots = game.maxPlayers - game.currentPlayers;
    final court = game.courtName != null ? ' en ${game.courtName}' : '';
    return '¡Sumate a "${game.name}"! '
        '${game.sportName ?? 'Partido'} · ${formatSchedule(game.scheduledAt)}'
        '$court. Quedan $spots lugares — te espero en DAFStudio.';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Copiar invitación',
      icon: const Icon(Icons.share_outlined),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: _invite()));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitación copiada — pegala donde quieras'),
            ),
          );
        }
      },
    );
  }
}
