import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_positions.dart';
import '../providers/games_providers.dart';

/// Joins [game] at slot [position] with the same UX rules as the main join
/// button: confirm dialog naming the side you're taking, level-range warning,
/// provider invalidation and friendly error snacks. Shared by the feed-card
/// slots and the detail court board.
Future<void> joinGameAtPosition(
  BuildContext context,
  WidgetRef ref,
  Game game,
  int position,
) async {
  final side = GamePositions.sideLabel(game.maxPlayers, position);

  // Same soft level check as GameActionButton: warn outside ±kLevelRange
  // of the organizer's ranking, but never block.
  final anchor = game.organizerRankingPoints;
  int mine;
  try {
    mine = await ref.read(mySportRankingProvider(game.sportId).future);
  } catch (_) {
    mine = anchor ?? 1000;
  }
  if (!context.mounted) return;

  var message = '¿Unirte a "${game.name}" en el $side?';
  if (anchor != null && (mine - anchor).abs() > kLevelRange) {
    final above = mine > anchor;
    message +=
        '\n\nOjo: el partido es de nivel ~$anchor pts (±$kLevelRange) y vos '
        'tenés $mine — estás por ${above ? 'encima' : 'debajo'} del rango.';
  }
  final ok = await showConfirmDialog(
    context,
    title: 'Elegir posición',
    message: message,
    confirmLabel: 'Unirme',
  );
  if (!ok || !context.mounted) return;

  try {
    await ref.read(gamesRepositoryProvider).join(game.id, position: position);
    ref.invalidate(gameByIdProvider(game.id));
    ref.invalidate(gamePlayersProvider(game.id));
    ref.invalidate(feedGamesProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Te uniste al partido')),
    );
  } catch (e) {
    if (!context.mounted) return;
    // A taken-position race still refreshes the roster so the slot updates.
    ref.invalidate(gamePlayersProvider(game.id));
    showErrorSnack(context, e);
  }
}
