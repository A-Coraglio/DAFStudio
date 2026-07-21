import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_providers.dart';

/// Profile entry to the password screen. Reads has_password to offer
/// "Cambiar" or "Crear" (cuentas Google sin contraseña propia).
class PasswordTile extends ConsumerWidget {
  const PasswordTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPassword =
        ref.watch(myAccountProvider).valueOrNull?.hasPassword ?? true;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lock_outline),
        title: Text(hasPassword ? 'Cambiar contraseña' : 'Crear contraseña'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/change-password'),
      ),
    );
  }
}
