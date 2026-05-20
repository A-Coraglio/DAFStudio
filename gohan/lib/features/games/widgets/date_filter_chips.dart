import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/games_providers.dart';

const _options = <({FeedDateFilter value, String label})>[
  (value: FeedDateFilter.all, label: 'Cualquier fecha'),
  (value: FeedDateFilter.today, label: 'Hoy'),
  (value: FeedDateFilter.week, label: 'Esta semana'),
];

/// Horizontal choice chips that drive `feedDateFilterProvider`.
class DateFilterChips extends ConsumerWidget {
  const DateFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(feedDateFilterProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final opt in _options) ...[
            ChoiceChip(
              label: Text(opt.label),
              selected: selected == opt.value,
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
