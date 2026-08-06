import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/teacher_providers.dart';
import 'teacher_lesson_tile.dart';

/// "Tus clases" del panel de profe: agenda con pendientes arriba.
class TeacherLessonsCard extends ConsumerWidget {
  const TeacherLessonsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teachingLessonsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tus clases',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            async.when(
              loading: () => const TileListSkeleton(rows: 3, shrinkWrap: true),
              error: (err, _) => ErrorView(
                error: err,
                onRetry: () => ref.invalidate(teachingLessonsProvider),
              ),
              data: (lessons) => lessons.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Todavía no tenés reservas. Cuando un alumno '
                        'reserve, la vas a ver acá para confirmarla.',
                      ),
                    )
                  : Column(
                      children: [
                        for (final l in lessons)
                          TeacherLessonTile(lesson: l),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
