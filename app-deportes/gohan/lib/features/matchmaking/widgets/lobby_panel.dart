import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../games/data/game.dart';
import '../../games/widgets/game_chat_button.dart';
import '../../games/widgets/game_info_card.dart';
import '../../games/widgets/game_players_list.dart';

/// Shown after the whole group accepted (`matched`). The game is live at
/// /games/:id so the user just needs a button to jump there.
class LobbyPanel extends StatelessWidget {
  const LobbyPanel({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '¡Todos aceptaron!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tu partido ya está armado. Nos vemos en la cancha.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GameInfoCard(game: game),
        const SizedBox(height: 16),
        Text('Jugadores', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GamePlayersList(gameId: game.id),
        const SizedBox(height: 16),
        GameChatButton(gameId: game.id),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go('/games/${game.id}'),
          icon: const Icon(Icons.sports),
          label: const Text('Ir al partido'),
        ),
      ],
    );
  }
}
