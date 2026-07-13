import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/games_providers.dart';

const _modes = <({String? value, String label})>[
  (value: null, label: 'Todos'),
  (value: 'casual', label: 'Casual'),
  (value: 'competitive', label: 'Competitivo'),
];

const _dates = <({FeedDateFilter value, String label})>[
  (value: FeedDateFilter.all, label: 'Cualquier fecha'),
  (value: FeedDateFilter.today, label: 'Hoy'),
  (value: FeedDateFilter.week, label: 'Esta semana'),
];

/// Mode + date filters in a single horizontally-scrollable row, so the
/// AppBar spends one chip row instead of two.
class FeedFilterRow extends ConsumerWidget {
  const FeedFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(feedModeFilterProvider);
    final date = ref.watch(feedDateFilterProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final opt in _modes) ...[
            ChoiceChip(
              label: Text(opt.label),
              selected: mode == opt.value,
              onSelected: (_) =>
                  ref.read(feedModeFilterProvider.notifier).set(opt.value),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          for (final opt in _dates) ...[
            ChoiceChip(
              label: Text(opt.label),
              selected: date == opt.value,
              onSelected: (_) =>
                  ref.read(feedDateFilterProvider.notifier).state = opt.value,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
