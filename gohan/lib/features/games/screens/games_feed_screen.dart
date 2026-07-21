import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_selector_button.dart';
import '../providers/games_providers.dart';
import '../widgets/feed_empty_state.dart';
import '../widgets/feed_filter_row.dart';
import '../widgets/feed_grouped_list.dart';
import '../widgets/feed_skeleton.dart';

class GamesFeedScreen extends ConsumerWidget {
  const GamesFeedScreen({super.key});

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(feedGamesProvider);
    await ref.read(feedGamesProvider.future);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(feedGamesProvider);
    final hasActiveSport = ref.watch(activeSportIdProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar partidos'),
        actions: const [SportSelectorButton()],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(height: 44, child: FeedFilterRow()),
          ),
        ),
      ),
      body: gamesAsync.when(
        loading: () => const FeedSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(feedGamesProvider),
        ),
        data: (games) => games.isEmpty
            ? FeedEmptyState(onCreate: () => context.push('/games/new'))
            : RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: FeedGroupedList(
                  games: games,
                  leading: hasActiveSport ? null : const _NoSportHint(),
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
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text('Elegí un deporte arriba para filtrar partidos.'),
          ),
        ],
      ),
    );
  }
}
