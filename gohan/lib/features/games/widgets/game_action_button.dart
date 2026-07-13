import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import '../providers/games_providers.dart';

/// Join / Leave button with all the state-dependent disabled variants.
///
/// Decides between join and leave based on whether the current user's
/// player_id is in the roster. Invalidates both game and roster providers
/// on success so the screen re-renders with fresh data.
class GameActionButton extends ConsumerStatefulWidget {
  const GameActionButton({
    super.key,
    required this.game,
    required this.players,
  });

  final Game game;
  final List<GamePlayer> players;

  @override
  ConsumerState<GameActionButton> createState() => _GameActionButtonState();
}

class _GameActionButtonState extends ConsumerState<GameActionButton> {
  bool _loading = false;

  Future<void> _run(
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _loading = true);
    try {
      await action();
      ref.invalidate(gameByIdProvider(widget.game.id));
      ref.invalidate(gamePlayersProvider(widget.game.id));
      ref.invalidate(feedGamesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;
    final repo = ref.read(gamesRepositoryProvider);
    final game = widget.game;
    final iAmIn =
        myPlayerId != null && widget.players.any((p) => p.playerId == myPlayerId);

    final (label, onPressed) = _resolve(game, iAmIn, repo);
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _loading || onPressed == null ? null : onPressed,
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  (String, VoidCallback?) _resolve(
    Game game,
    bool iAmIn,
    dynamic repo,
  ) {
    if (game.status == 'finished') return ('Finalizado', null);
    if (game.status == 'cancelled') return ('Cancelado', null);
    if (game.status == 'pending_acceptance') {
      return ('Esperando aceptación', null);
    }
    if (iAmIn) {
      return (
        'Salir del partido',
        () async {
          final ok = await showConfirmDialog(
            context,
            title: 'Salir del partido',
            message: '¿Seguro que querés bajarte? Tu lugar queda libre.',
            confirmLabel: 'Salir',
            destructive: true,
          );
          if (ok) _run(() => repo.leave(game.id), 'Saliste del partido');
        },
      );
    }
    if (game.isFull) return ('Completo', null);
    return (
      'Unirme',
      () => _run(() => repo.join(game.id), 'Te uniste al partido'),
    );
  }
}
