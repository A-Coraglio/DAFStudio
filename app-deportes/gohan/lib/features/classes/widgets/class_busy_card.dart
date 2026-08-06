import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../lessons/providers/lessons_providers.dart';

/// "Horarios ocupados" del profe: los próximos slots tomados de su agenda,
/// para ver un choque ANTES de reservar (y no recién con el 409).
class ClassBusyCard extends ConsumerWidget {
  const ClassBusyCard({super.key, required this.teacherId});

  final int teacherId;

  static const _maxShown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots =
        ref.watch(teacherBusySlotsProvider(teacherId)).valueOrNull ?? const [];
    if (slots.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final shown = slots.take(_maxShown).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horarios ya ocupados',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final s in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: scheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      '${formatSchedule(s.start)} – ${formatHour(s.end)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (slots.length > _maxShown)
              Text(
                'y ${slots.length - _maxShown} más…',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
