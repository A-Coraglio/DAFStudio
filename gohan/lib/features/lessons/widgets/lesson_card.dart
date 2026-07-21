import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../sports/providers/sports_providers.dart';
import '../data/lesson_model.dart';
import 'lesson_cancel_button.dart';
import 'lesson_status_chip.dart';

/// Card for one booked lesson: teacher, time range, price, and either the
/// cancel action (upcoming) or a status chip (past / cancelled).
class LessonCard extends ConsumerWidget {
  const LessonCard({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    String? sportName;
    for (final s in sports) {
      if (s.id == lesson.sportId) sportName = s.name;
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => context.push('/classes/${lesson.teacherId}'),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.school_outlined, color: scheme.onPrimaryContainer),
        ),
        title: Text(
          sportName == null
              ? 'Clase con ${lesson.teacherName}'
              : 'Clase de $sportName con ${lesson.teacherName}',
        ),
        subtitle: Text(
          '${formatSchedule(lesson.startTime)} – '
          '${formatHour(lesson.endTime)} · '
          '\$${lesson.totalPrice.round()}',
        ),
        trailing: lesson.isActive
            ? LessonCancelButton(lesson: lesson)
            : LessonStatusChip(lesson: lesson),
      ),
    );
  }
}
