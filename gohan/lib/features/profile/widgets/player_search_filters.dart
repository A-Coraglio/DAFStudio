import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/providers/sports_providers.dart';
import '../data/player_search_query.dart';

const _levels = <String>['beginner', 'intermediate', 'advanced'];

/// Two rows of selectable chips: sport (favorite) and level. Edits the
/// passed [query] via [onChanged] — the parent owns the state.
class PlayerSearchFilters extends ConsumerWidget {
  const PlayerSearchFilters({
    super.key,
    required this.query,
    required this.onChanged,
  });

  final PlayerSearchQuery query;
  final ValueChanged<PlayerSearchQuery> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsAsync = ref.watch(sportsListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: sportsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (sports) => ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in sports)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.name),
                      selected: query.sportId == s.id,
                      onSelected: (sel) => onChanged(
                        sel
                            ? query.copyWith(sportId: s.id)
                            : query.copyWith(clearSport: true),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final lvl in _levels)
              FilterChip(
                label: Text(lvl),
                selected: query.level == lvl,
                onSelected: (sel) => onChanged(
                  sel
                      ? query.copyWith(level: lvl)
                      : query.copyWith(clearLevel: true),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
