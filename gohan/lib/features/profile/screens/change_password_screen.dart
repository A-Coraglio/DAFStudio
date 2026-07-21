import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../providers/profile_providers.dart';
import '../widgets/change_password_form.dart';

/// "Cambiar contraseña" (o "Crear contraseña" para cuentas Google que nunca
/// setearon una) — el flag has_password del backend decide qué flujo es.
class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(myAccountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Contraseña')),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myAccountProvider),
        ),
        data: (account) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!account.hasPassword) ...[
              Text(
                'Tu cuenta entró con Google y todavía no tiene contraseña '
                'propia. Creá una para poder entrar también con email.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            ChangePasswordForm(
              userId: account.id,
              hasPassword: account.hasPassword,
            ),
          ],
        ),
      ),
    );
  }
}
