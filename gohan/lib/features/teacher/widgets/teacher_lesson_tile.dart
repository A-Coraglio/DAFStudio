import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/labels.dart';
import '../../lessons/data/lesson_model.dart';
import '../../lessons/providers/lessons_providers.dart';
import '../providers/teacher_providers.dart';
import 'teacher_lesson_actions.dart';

/// Una clase en la agenda del profe: alumno + horario + estado + acciones.
class TeacherLessonTile extends ConsumerStatefulWidget {
  const TeacherLessonTile({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<TeacherLessonTile> createState() => _TeacherLessonTileState();
}

class _TeacherLessonTileState extends ConsumerState<TeacherLessonTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() op, String msg) async {
    setState(() => _busy = true);
    try {
      await op();
      ref.invalidate(teachingLessonsProvider);
      ref.invalidate(teacherBusySlotsProvider(widget.lesson.teacherId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final repo = ref.read(lessonsRepositoryProvider);
    return ListTile(
      title: Text(l.studentName == null ? 'Clase' : 'Con ${l.studentName}'),
      subtitle: Text(
        '${formatSchedule(l.startTime)} – ${formatHour(l.endTime)} · '
        '\$${l.totalPrice.round()} · ${lessonStatusLabel(l.status)}',
      ),
      trailing: TeacherLessonActions(
        lesson: l,
        busy: _busy,
        onConfirm: () => _run(() => repo.confirm(l.id), 'Clase confirmada'),
        onReject: () => _run(() => repo.reject(l.id), 'Clase rechazada'),
        onCancel: () =>
            _run(() => repo.teacherCancel(l.id), 'Clase cancelada'),
      ),
    );
  }
}
