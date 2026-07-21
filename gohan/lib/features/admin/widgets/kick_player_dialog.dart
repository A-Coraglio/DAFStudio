import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../games/data/game.dart';
import '../../games/providers/games_providers.dart';
import '../../profile/widgets/profile_avatar.dart';
import 'run_admin_action.dart';

/// Diálogo admin "Sacar a un jugador": lista el roster del partido y al
/// tocar uno corre la acción con confirmación.
Future<void> showKickPlayerDialog(
  BuildContext context,
  WidgetRef ref,
  Game game,
) async {
  final players = await ref.read(gamePlayersProvider(game.id).future);
  if (!context.mounted) return;
  if (players.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El partido no tiene jugadores')),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('¿A quién sacás del partido?'),
      children: [
        for (final p in players)
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              runAdminAction(
                context, ref,
                title: 'Sacar jugador (admin)',
                message: '¿Sacar a ${p.displayName} de "${game.name}"?',
                confirmLabel: 'Sacar',
                op: (repo) => repo.kickPlayer(game.id, p.playerId),
                successMsg: '${p.displayName} fue sacado del partido',
                onDone: (ref) {
                  ref.invalidate(gameByIdProvider(game.id));
                  ref.invalidate(gamePlayersProvider(game.id));
                  ref.invalidate(feedGamesProvider);
                },
              );
            },
            child: Row(
              children: [
                ProfileAvatar(
                  avatarUrl: p.avatarUrl,
                  initials: p.initials,
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(p.displayName)),
              ],
            ),
          ),
      ],
    ),
  );
}
