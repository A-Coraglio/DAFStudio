import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/admin_providers.dart';

/// Auditoría: quién hizo qué acción de administración y cuándo.
class AdminAuditScreen extends ConsumerWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminAuditProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditoría'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminAuditProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const TileListSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(adminAuditProvider),
        ),
        data: (entries) => entries.isEmpty
            ? const IllustratedEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Sin acciones registradas',
                body: 'Acá queda el historial de bans, eliminaciones y '
                    'demás acciones de administración.',
              )
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final e = entries[i];
                  final target = e.targetType == 'game'
                      ? 'partido #${e.targetId}'
                      : 'usuario #${e.targetId}';
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text('@${e.adminUsername} — ${e.actionLabel} $target'),
                    subtitle: Text(
                      e.detail == null
                          ? formatMessageTime(e.createdAt)
                          : '${e.detail} · ${formatMessageTime(e.createdAt)}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}
