import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_selector_button.dart';
import '../providers/games_providers.dart';
import '../widgets/date_filter_chips.dart';
import '../widgets/feed_empty_state.dart';
import '../widgets/feed_skeleton.dart';
import '../widgets/game_card.dart';
import '../widgets/mode_filter_chips.dart';

class GamesFeedScreen extends ConsumerWidget {
  const GamesFeedScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(feedGamesProvider);
    await ref.read(feedGamesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(filteredFeedGamesProvider);
    final hasActiveSport = ref.watch(activeSportIdProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar partidos'),
        actions: const [SportSelectorButton()],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(104),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 44, child: ModeFilterChips()),
                SizedBox(height: 8),
                SizedBox(height: 44, child: DateFilterChips()),
              ],
            ),
          ),
        ),
      ),
      body: gamesAsync.when(
        loading: () => const FeedSkeleton(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(feedGamesProvider),
        ),
        data: (games) => games.isEmpty
            ? FeedEmptyState(onCreate: () => context.push('/games/new'))
            : RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: games.length + (hasActiveSport ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (!hasActiveSport && index == 0) {
                      return const _NoSportHint();
                    }
                    final game = games[hasActiveSport ? index : index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GameCard(
                        game: game,
                        onTap: () => context.push('/games/${game.id}'),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'createGameFab',
        onPressed: () => context.push('/games/new'),
        icon: const Icon(Icons.add),
        label: const Text('Crear'),
      ),
    );
  }
}

class _NoSportHint extends StatelessWidget {
  const _NoSportHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Elegí un deporte arriba para filtrar partidos.',
            ),
          ),
        ],
      ),
    );
  }
}
