import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/lesson_model.dart';
import '../providers/lessons_providers.dart';

/// Trailing "cancelar" action of an upcoming lesson, with confirmation.
class LessonCancelButton extends ConsumerStatefulWidget {
  const LessonCancelButton({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<LessonCancelButton> createState() =>
      _LessonCancelButtonState();
}

class _LessonCancelButtonState extends ConsumerState<LessonCancelButton> {
  bool _busy = false;

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancelar clase',
      message:
          '¿Seguro que querés cancelar tu clase con '
          '${widget.lesson.teacherName}?',
      confirmLabel: 'Cancelar clase',
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(lessonsRepositoryProvider).cancel(widget.lesson.id);
      ref.invalidate(myLessonsProvider);
      ref.invalidate(teacherBusySlotsProvider(widget.lesson.teacherId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clase cancelada')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      tooltip: 'Cancelar clase',
      icon: const Icon(Icons.close),
      onPressed: _cancel,
    );
  }
}
