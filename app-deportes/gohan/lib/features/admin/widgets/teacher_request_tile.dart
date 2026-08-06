import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/providers/sports_providers.dart';
import '../data/teacher_request_row.dart';
import 'teacher_request_actions.dart';

/// Solicitud de profe en la cola del admin, con aprobar/rechazar.
class TeacherRequestTile extends ConsumerWidget {
  const TeacherRequestTile({super.key, required this.request});

  final TeacherRequestRow request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    final names = [
      for (final id in request.sportIds)
        for (final s in sports)
          if (s.id == id) s.name,
    ].join(' · ');
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.displayName} (@${request.username ?? '-'})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text('$names · \$${request.pricePerHour.round()}/h'
                '${request.experienceYears == null ? '' : ' · ${request.experienceYears} años'}'),
            const SizedBox(height: 4),
            Text(
              request.bio,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TeacherRequestActions(request: request),
          ],
        ),
      ),
    );
  }
}
