import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/admin_providers.dart';
import '../widgets/teacher_request_tile.dart';

/// Cola de solicitudes "quiero ser profe" pendientes.
class AdminTeacherRequestsScreen extends ConsumerWidget {
  const AdminTeacherRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminTeacherRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de profe')),
      body: async.when(
        loading: () => const TileListSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(adminTeacherRequestsProvider),
        ),
        data: (requests) => requests.isEmpty
            ? const IllustratedEmptyState(
                icon: Icons.school_outlined,
                title: 'Sin solicitudes pendientes',
                body: 'Cuando alguien pida ser profe, la solicitud '
                    'aparece acá para aprobarla o rechazarla.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    TeacherRequestTile(request: requests[i]),
              ),
      ),
    );
  }
}
