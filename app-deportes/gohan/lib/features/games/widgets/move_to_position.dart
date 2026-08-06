import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/game.dart';
import '../data/game_positions.dart';
import '../providers/games_providers.dart';

/// Moves the current user (already in [game]) to slot [position], with a
/// confirm naming the side. Shared by the feed-card slots and the detail
/// court board — the re-position counterpart of joinGameAtPosition.
Future<void> moveToPosition(
  BuildContext context,
  WidgetRef ref,
  Game game,
  int position,
) async {
  final side = GamePositions.sideLabel(game.maxPlayers, position);
  final ok = await showConfirmDialog(
    context,
    title: 'Cambiar de posición',
    message: '¿Pasarte a ese lugar del $side?',
    confirmLabel: 'Cambiarme',
  );
  if (!ok || !context.mounted) return;

  try {
    await ref.read(gamesRepositoryProvider).move(game.id, position: position);
    ref.invalidate(gameByIdProvider(game.id));
    ref.invalidate(gamePlayersProvider(game.id));
    ref.invalidate(feedGamesProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambiaste de posición')),
    );
  } catch (e) {
    if (!context.mounted) return;
    // A taken-slot race still refreshes the roster so the board updates.
    ref.invalidate(gamePlayersProvider(game.id));
    ref.invalidate(feedGamesProvider);
    showErrorSnack(context, e);
  }
}
