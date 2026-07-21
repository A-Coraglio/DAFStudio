import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../providers/games_providers.dart';
import '../widgets/game_action_button.dart';
import '../widgets/game_detail_skeleton.dart';
import '../widgets/game_chat_app_bar_action.dart';
import '../widgets/game_info_card.dart';
import '../widgets/game_organizer_menu.dart';
import '../widgets/game_players_list.dart';
import '../widgets/game_share_action.dart';
import '../widgets/position_board.dart';
import '../widgets/report_progress_hint.dart';
import '../widgets/report_result_button.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.gameId});

  final int gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameByIdProvider(gameId));
    final playersAsync = ref.watch(gamePlayersProvider(gameId));
    final game = gameAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          game?.name ?? 'Partido',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          GameChatAppBarAction(gameId: gameId),
          if (game != null) GameShareAction(game: game),
          if (game != null) GameOrganizerMenu(game: game),
        ],
      ),
      body: gameAsync.when(
        loading: () => const GameDetailSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(gameByIdProvider(gameId)),
        ),
        data: (game) => RefreshIndicator(
          onRefresh: () => safeRefresh(() async {
            ref.invalidate(gameByIdProvider(gameId));
            ref.invalidate(gamePlayersProvider(gameId));
            await ref.read(gameByIdProvider(gameId).future);
          }),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GameInfoCard(game: game),
              const SizedBox(height: 16),
              PositionBoard(game: game),
              const SizedBox(height: 16),
              Text('Jugadores', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GamePlayersList(gameId: gameId),
              const SizedBox(height: 20),
              GameActionButton(
                game: game,
                players: playersAsync.valueOrNull ?? const [],
              ),
              const SizedBox(height: 8),
              ReportProgressHint(game: game),
              ReportResultButton(
                game: game,
                players: playersAsync.valueOrNull ?? const [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
