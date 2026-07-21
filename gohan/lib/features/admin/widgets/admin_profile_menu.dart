import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';
import '../providers/admin_providers.dart';
import 'run_admin_action.dart';

/// Menú admin del perfil público de otro jugador: banear/desbanear y
/// eliminar la cuenta. Invisible si no sos admin o si es tu propio perfil.
class AdminProfileMenu extends ConsumerWidget {
  const AdminProfileMenu({
    super.key,
    required this.targetUserId,
    required this.displayName,
  });

  final int targetUserId;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final myUserId = ref.watch(myProfileProvider).valueOrNull?.userId;
    if (!isAdmin || targetUserId == myUserId) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Acciones de admin',
      icon: const Icon(Icons.shield_outlined),
      onSelected: (action) => switch (action) {
        'ban' => runAdminAction(
            context, ref,
            title: 'Banear usuario',
            message: '¿Banear a $displayName? No va a poder entrar más '
                '(y su sesión actual se corta al instante).',
            confirmLabel: 'Banear',
            op: (repo) => repo.ban(targetUserId),
            successMsg: '$displayName baneado',
          ),
        'unban' => runAdminAction(
            context, ref,
            title: 'Levantar ban',
            message: '¿Desbanear a $displayName?',
            confirmLabel: 'Desbanear',
            destructive: false,
            op: (repo) => repo.unban(targetUserId),
            successMsg: '$displayName desbaneado',
          ),
        'delete' => runAdminAction(
            context, ref,
            title: 'Eliminar cuenta',
            message: '¿Eliminar la cuenta de $displayName? Se anonimiza y '
                'no se puede deshacer.',
            confirmLabel: 'Eliminar',
            op: (repo) => repo.deleteUser(targetUserId),
            successMsg: 'Cuenta de $displayName eliminada',
          ),
        _ => null,
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'ban', child: Text('Banear')),
        PopupMenuItem(value: 'unban', child: Text('Desbanear')),
        PopupMenuItem(value: 'delete', child: Text('Eliminar cuenta')),
      ],
    );
  }
}
