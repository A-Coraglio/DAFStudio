import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../admin/providers/admin_providers.dart';

/// Entrada al panel de administración — solo visible para admins.
class AdminTile extends ConsumerWidget {
  const AdminTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAdminProvider)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.shield_outlined),
          title: const Text('Administración'),
          subtitle: const Text('Usuarios, auditoría y logs'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/admin'),
        ),
      ),
    );
  }
}
