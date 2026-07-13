import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/profile_providers.dart';
import '../widgets/my_game_tile.dart';

/// Personal game history with a mode filter (all / competitive / casual).
class MyGamesScreen extends ConsumerStatefulWidget {
  const MyGamesScreen({super.key});

  @override
  ConsumerState<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends ConsumerState<MyGamesScreen> {
  String? _mode; // null = todos

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myGamesProvider(_mode));
    return Scaffold(
      appBar: AppBar(title: const Text('Mis partidos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _mode == null,
                  onSelected: (_) => setState(() => _mode = null),
                ),
                ChoiceChip(
                  label: const Text('Competitivos'),
                  selected: _mode == 'competitive',
                  onSelected: (_) => setState(() => _mode = 'competitive'),
                ),
                ChoiceChip(
                  label: const Text('Casuales'),
                  selected: _mode == 'casual',
                  onSelected: (_) => setState(() => _mode = 'casual'),
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const TileListSkeleton(),
              error: (err, _) => ErrorView(
                error: err,
                onRetry: () => ref.invalidate(myGamesProvider(_mode)),
              ),
              data: (games) {
                if (games.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Todavía no jugaste partidos en esta categoría.',
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(myGamesProvider(_mode));
                    ref.invalidate(myStatsProvider);
                    await ref.read(myGamesProvider(_mode).future);
                  },
                  child: ListView.separated(
                    itemCount: games.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => MyGameTile(game: games[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
