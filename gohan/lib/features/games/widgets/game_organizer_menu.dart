import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/errors/error_snackbar.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../providers/games_providers.dart';
import 'edit_game_sheet.dart';

/// "⋮" AppBar menu visible only to the game's organizer while the game is
/// still alive — edit the basics or cancel it altogether.
class GameOrganizerMenu extends ConsumerWidget {
  const GameOrganizerMenu({super.key, required this.game});

  final Game game;

  Future<void> _cancelGame(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancelar partido',
      message: 'Se cancela para todos los anotados. ¿Seguro?',
      confirmLabel: 'Cancelar partido',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref
          .read(gamesRepositoryProvider)
          .update(game.id, status: 'cancelled');
      ref.invalidate(gameByIdProvider(game.id));
      ref.invalidate(feedGamesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Partido cancelado')));
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.watch(myProfileProvider).valueOrNull?.userId;
    final alive = game.status == 'open' || game.status == 'full';
    if (myUserId == null || myUserId != game.organizerId || !alive) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<String>(
      tooltip: 'Opciones del organizador',
      onSelected: (v) => v == 'edit'
          ? EditGameSheet.show(context, game)
          : _cancelGame(context, ref),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Editar partido')),
        PopupMenuItem(value: 'cancel', child: Text('Cancelar partido')),
      ],
    );
  }
}
