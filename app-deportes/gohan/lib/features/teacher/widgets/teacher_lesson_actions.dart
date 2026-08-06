import 'package:flutter/material.dart';

import '../../lessons/data/lesson_model.dart';

/// Trailing de una clase del profe: confirmar/rechazar (pendiente) o
/// cancelar (confirmada). El tile ejecuta las acciones.
class TeacherLessonActions extends StatelessWidget {
  const TeacherLessonActions({
    super.key,
    required this.lesson,
    required this.busy,
    required this.onConfirm,
    required this.onReject,
    required this.onCancel,
  });

  final Lesson lesson;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (!lesson.isActive) return const SizedBox.shrink();
    if (lesson.isPending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Confirmar',
            icon: Icon(Icons.check, color: scheme.primary),
            onPressed: onConfirm,
          ),
          IconButton(
            tooltip: 'Rechazar',
            icon: Icon(Icons.close, color: scheme.error),
            onPressed: onReject,
          ),
        ],
      );
    }
    return IconButton(
      tooltip: 'Cancelar clase',
      icon: const Icon(Icons.event_busy),
      onPressed: onCancel,
    );
  }
}
