import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorView(
                error: err,
                message: 'No pudimos cargar los torneos.',
                onRetry: () => ref.invalidate(tournamentsFetchProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: items.isEmpty
                    ? const _Empty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => TournamentCard(
                          tournament: items[i],
                          // No dedicated detail screen yet — v1 lists only.
                          onTap: () {},
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Scrollable so pull-to-refresh still works when the filtered list is
      // empty.
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined, size: 48),
              SizedBox(height: 12),
              Text('No hay torneos con esos filtros'),
            ],
          ),
        ),
      ],
    );
  }
}
