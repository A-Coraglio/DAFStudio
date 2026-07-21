import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub de administración: entradas a usuarios, auditoría y logs. Las
/// acciones sobre partidos son contextuales (menú admin en el detalle).
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Usuarios'),
              subtitle: const Text('Buscar, banear, eliminar, dar rol admin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/users'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Solicitudes de profe'),
              subtitle: const Text('Aprobar o rechazar postulaciones'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/teacher-requests'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.stadium_outlined),
              title: const Text('Crear club'),
              subtitle: const Text('Alta de club con dueño asignado'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/create-club'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Auditoría'),
              subtitle: const Text('Historial de acciones de administración'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/audit'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.terminal_outlined),
              title: const Text('Logs del server'),
              subtitle: const Text('Últimas líneas de actividad y errores'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/logs'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Para cancelar un partido o sacar a un jugador, entrá al '
            'partido: como admin tenés un menú extra ahí.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
