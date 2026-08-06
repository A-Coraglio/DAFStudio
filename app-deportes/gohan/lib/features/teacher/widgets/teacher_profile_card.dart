import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/providers/sports_providers.dart';
import '../data/teacher_profile.dart';
import 'teacher_edit_sheet.dart';

/// Resumen del perfil de profe con acceso a editarlo.
class TeacherProfileCard extends ConsumerWidget {
  const TeacherProfileCard({super.key, required this.teacher});

  final TeacherProfile teacher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    final names = [
      for (final id in teacher.sportIds)
        for (final s in sports)
          if (s.id == id) s.name,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    names.isEmpty ? 'Tu perfil de profe' : names.join(' · '),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Editar perfil de profe',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => TeacherEditSheet.show(context, teacher),
                ),
              ],
            ),
            if (teacher.bio != null && teacher.bio!.isNotEmpty)
              Text(
                teacher.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Text(
              '\$${teacher.pricePerHour.round()}/h'
              '${teacher.experienceYears == null ? '' : ' · ${teacher.experienceYears} años de experiencia'}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
