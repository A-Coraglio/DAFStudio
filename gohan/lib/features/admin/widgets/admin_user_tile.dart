import 'package:flutter/material.dart';

import '../data/admin_user.dart';
import 'admin_user_menu.dart';

/// Fila del listado de usuarios: identidad + estado + menú de acciones.
class AdminUserTile extends StatelessWidget {
  const AdminUserTile({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        child: Text(user.displayName.isEmpty
            ? '?'
            : user.displayName[0].toUpperCase()),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isAdmin) ...[
            const SizedBox(width: 6),
            Icon(Icons.shield, size: 16, color: scheme.primary),
          ],
          if (user.isBanned) ...[
            const SizedBox(width: 6),
            Text(
              'BANEADO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (user.isDeleted) ...[
            const SizedBox(width: 6),
            Text(
              'ELIMINADA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '@${user.username} · ${user.email}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AdminUserMenu(user: user),
    );
  }
}
