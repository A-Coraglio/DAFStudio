import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../teacher/providers/teacher_providers.dart';

/// Entrada al modo profesor: panel si ya sos profe, estado de la solicitud
/// si está pendiente, o "Quiero ser profe" para postularte.
class TeacherTile extends ConsumerWidget {
  const TeacherTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(myTeacherStatusProvider).valueOrNull;
    if (status == null) return const SizedBox.shrink();

    final (title, subtitle, route) = status.isTeacher
        ? ('Panel de profesor', 'Tu perfil y tus clases', '/teacher')
        : status.hasPendingRequest
        ? ('Solicitud de profe enviada', 'Un admin la está revisando', null)
        : status.wasRejected
        ? ('Quiero ser profe', 'Tu solicitud anterior fue rechazada — '
              'podés volver a intentar', '/teacher/apply')
        : ('Quiero ser profe', 'Postulate para dar clases', '/teacher/apply');

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.sports_outlined),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: route == null
              ? const Icon(Icons.hourglass_top)
              : const Icon(Icons.chevron_right),
          onTap: route == null ? null : () => context.push(route),
        ),
      ),
    );
  }
}
