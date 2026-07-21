import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../providers/admin_providers.dart';

/// Visor de logs del server (últimas líneas de logs/server.log), más nuevas
/// arriba. Texto seleccionable para copiar un stacktrace.
class AdminLogsScreen extends ConsumerWidget {
  const AdminLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminLogsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs del server'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminLogsProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(adminLogsProvider),
        ),
        data: (lines) => lines.isEmpty
            ? const Center(child: Text('El log está vacío todavía.'))
            : ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: lines.length,
                itemBuilder: (_, i) => SelectableText(
                  lines[lines.length - 1 - i],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
      ),
    );
  }
}
