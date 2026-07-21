import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/tournaments_providers.dart';
import '../widgets/tournament_card.dart';
import '../widgets/tournaments_filter_bar.dart';

/// Full tournaments search/list, reached from the home carousel's "Ver todos".
class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(tournamentsFetchProvider);
    await ref.read(tournamentsListProvider.future);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tournamentsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Torneos')),
      body: Column(
        children: [
          const TournamentsFilterBar(),
          Expanded(
            child: async.when(
              loading: () => const TileListSkeleton(),
              error: (err, _) => ErrorView(
                error: err,
                message: 'No pudimos cargar los torneos.',
                onRetry: () => ref.invalidate(tournamentsFetchProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: items.isEmpty
                    ? ListView(
                        // Scrollable so pull-to-refresh still works when the
                        // filtered list is empty.
                        children: const [
                          SizedBox(height: 40),
                          IllustratedEmptyState(
                            icon: Icons.emoji_events_outlined,
                            title: 'No hay torneos',
                            body:
                                'Probá con otros filtros, o volvé más '
                                'adelante: siempre aparecen torneos nuevos.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => TournamentCard(
                          tournament: items[i],
                          onTap: () =>
                              context.push('/tournaments/${items[i].id}'),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
