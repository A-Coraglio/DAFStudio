import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/format/dates.dart';
import '../data/game.dart';

/// AppBar action that opens the native share sheet with a ready-to-paste
/// invite for the game. Where sharing isn't available (some desktop
/// browsers), it falls back to copying the text to the clipboard.
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

  Future<void> _share(BuildContext context) async {
    final invite = _invite();
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: invite),
      );
      if (result.status != ShareResultStatus.unavailable) return;
    } catch (_) {
      // Fall through to the clipboard fallback below.
    }
    await Clipboard.setData(ClipboardData(text: invite));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitación copiada — pegala donde quieras'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Compartir partido',
      icon: const Icon(Icons.share_outlined),
      onPressed: () => _share(context),
    );
  }
}
