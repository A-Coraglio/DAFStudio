import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_user.dart';
import 'run_admin_action.dart';

/// Menú de acciones sobre un usuario del panel: ban/desban, eliminar,
/// dar/quitar rol admin. El backend valida los casos borde (auto-ban,
/// último admin, banear a otro admin).
class AdminUserMenu extends ConsumerWidget {
  const AdminUserMenu({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user.displayName;
    return PopupMenuButton<String>(
      tooltip: 'Acciones',
      onSelected: (action) => switch (action) {
        'ban' => runAdminAction(
            context, ref,
            title: 'Banear usuario',
            message: '¿Banear a $name? No va a poder entrar más '
                '(y su sesión actual se corta al instante).',
            confirmLabel: 'Banear',
            op: (repo) => repo.ban(user.userId),
            successMsg: '$name baneado',
          ),
        'unban' => runAdminAction(
            context, ref,
            title: 'Levantar ban',
            message: '¿Desbanear a $name? Va a poder entrar de nuevo.',
            confirmLabel: 'Desbanear',
            destructive: false,
            op: (repo) => repo.unban(user.userId),
            successMsg: '$name desbaneado',
          ),
        'delete' => runAdminAction(
            context, ref,
            title: 'Eliminar cuenta',
            message: '¿Eliminar la cuenta de $name? Se anonimiza y no se '
                'puede deshacer (los historiales ajenos se conservan).',
            confirmLabel: 'Eliminar',
            op: (repo) => repo.deleteUser(user.userId),
            successMsg: 'Cuenta de $name eliminada',
          ),
        'promote' => runAdminAction(
            context, ref,
            title: 'Hacer admin',
            message: '¿Dar permisos de administración a $name?',
            confirmLabel: 'Hacer admin',
            destructive: false,
            op: (repo) => repo.promote(user.userId),
            successMsg: '$name ahora es admin',
          ),
        'demote' => runAdminAction(
            context, ref,
            title: 'Quitar rol admin',
            message: '¿Quitarle los permisos de administración a $name?',
            confirmLabel: 'Quitar rol',
            op: (repo) => repo.demote(user.userId),
            successMsg: '$name ya no es admin',
          ),
        _ => null,
      },
      itemBuilder: (_) => [
        if (!user.isDeleted) ...[
          user.isBanned
              ? const PopupMenuItem(value: 'unban', child: Text('Desbanear'))
              : const PopupMenuItem(value: 'ban', child: Text('Banear')),
          const PopupMenuItem(value: 'delete', child: Text('Eliminar cuenta')),
          user.isAdmin
              ? const PopupMenuItem(
                  value: 'demote', child: Text('Quitar rol admin'))
              : const PopupMenuItem(
                  value: 'promote', child: Text('Hacer admin')),
        ],
      ],
    );
  }
}
