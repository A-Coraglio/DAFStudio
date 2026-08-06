import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../data/lesson_model.dart';

/// Trailing label of a lesson that can no longer be cancelled: "Cancelada"
/// in error color, "Pasada" for lessons that already happened.
class LessonStatusChip extends StatelessWidget {
  const LessonStatusChip({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = lesson.isCancelled
        ? lessonStatusLabel(lesson.status)
        : 'Pasada';
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: lesson.isCancelled ? scheme.error : scheme.onSurfaceVariant,
      ),
    );
  }
}
