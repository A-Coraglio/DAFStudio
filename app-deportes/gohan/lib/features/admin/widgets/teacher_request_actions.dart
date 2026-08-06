import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../teacher/providers/teacher_providers.dart';
import '../data/teacher_request_row.dart';
import '../providers/admin_providers.dart';
import 'run_admin_action.dart';

/// Botonera aprobar/rechazar de una solicitud de profe.
class TeacherRequestActions extends ConsumerWidget {
  const TeacherRequestActions({super.key, required this.request});

  final TeacherRequestRow request;

  void _afterResolve(WidgetRef ref) {
    ref.invalidate(adminTeacherRequestsProvider);
    ref.invalidate(myTeacherStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => runAdminAction(
            context, ref,
            title: 'Rechazar solicitud',
            message: '¿Rechazar la solicitud de ${request.displayName}?',
            confirmLabel: 'Rechazar',
            op: (repo) => repo.rejectTeacherRequest(request.id),
            successMsg: 'Solicitud rechazada',
            onDone: _afterResolve,
          ),
          child: const Text('Rechazar'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => runAdminAction(
            context, ref,
            title: 'Aprobar solicitud',
            message: '¿Aprobar a ${request.displayName} como profe? '
                'Va a aparecer en Clases al instante.',
            confirmLabel: 'Aprobar',
            destructive: false,
            op: (repo) => repo.approveTeacherRequest(request.id),
            successMsg: '${request.displayName} ya es profe',
            onDone: _afterResolve,
          ),
          child: const Text('Aprobar'),
        ),
      ],
    );
  }
}
