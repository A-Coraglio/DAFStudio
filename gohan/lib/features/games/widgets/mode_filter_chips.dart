import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/games_providers.dart';

const _options = <({String? value, String label})>[
  (value: null, label: 'Todos'),
  (value: 'casual', label: 'Casual'),
  (value: 'competitive', label: 'Competitivo'),
  (value: 'matchmaking', label: 'Matchmaking'),
];

/// Horizontal choice chips that drive `feedModeFilterProvider`.
class ModeFilterChips extends ConsumerWidget {
  const ModeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(feedModeFilterProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final opt in _options) ...[
            ChoiceChip(
              label: Text(opt.label),
              selected: selected == opt.value,
              onSelected: (_) {
                ref.read(feedModeFilterProvider.notifier).state = opt.value;
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
