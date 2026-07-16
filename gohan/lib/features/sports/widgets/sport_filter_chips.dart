import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sports_providers.dart';

/// Horizontally-scrollable "Todos + one chip per sport" filter, bound to the
/// live sports list. `selected == null` means no sport filter. Reused by the
/// tournaments and classes search screens.
class SportFilterChips extends ConsumerWidget {
  const SportFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final s in sports) ...[
            ChoiceChip(
              label: Text(s.name),
              selected: selected == s.id,
              onSelected: (_) => onChanged(s.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
