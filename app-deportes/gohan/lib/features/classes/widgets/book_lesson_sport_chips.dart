import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/providers/sports_providers.dart';

/// Sport selector of the booking sheet — only rendered when the teacher
/// offers more than one sport.
class BookLessonSportChips extends ConsumerWidget {
  const BookLessonSportChips({
    super.key,
    required this.sportIds,
    required this.selected,
    required this.onChanged,
  });

  final List<int> sportIds;
  final int? selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    String nameOf(int id) {
      for (final s in sports) {
        if (s.id == id) return s.name;
      }
      return 'Deporte #$id';
    }

    return Wrap(
      spacing: 8,
      children: [
        for (final id in sportIds)
          ChoiceChip(
            label: Text(nameOf(id)),
            selected: selected == id,
            onSelected: (_) => onChanged(id),
          ),
      ],
    );
  }
}
