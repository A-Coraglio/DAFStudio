import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../lessons/providers/lessons_providers.dart';
import '../../lessons/widgets/lesson_cancel_button.dart';

/// "Tus clases con este profe": the caller's upcoming lessons with this
/// teacher, each cancellable. Hidden when there are none.
class ClassLessonsCard extends ConsumerWidget {
  const ClassLessonsCard({super.key, required this.teacherId});

  final int teacherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(myLessonsProvider).valueOrNull ?? const [];
    final upcoming = lessons
        .where((l) => l.teacherId == teacherId && l.isActive)
        .toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tus clases con este profe',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final lesson in upcoming)
              ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: Text(
                  '${formatSchedule(lesson.startTime)} – '
                  '${formatHour(lesson.endTime)}',
                ),
                subtitle: Text('\$${lesson.totalPrice.round()}'),
                trailing: LessonCancelButton(lesson: lesson),
              ),
          ],
        ),
      ),
    );
  }
}
