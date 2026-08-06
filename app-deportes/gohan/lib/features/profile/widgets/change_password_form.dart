import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../auth/widgets/password_field.dart';
import '../providers/profile_providers.dart';

/// Password form: current (only when the account has one), new and repeat.
class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({
    super.key,
    required this.userId,
    required this.hasPassword,
  });

  final int userId;

  /// False = Google account without a password yet: the first set is free.
  final bool hasPassword;

  @override
  ConsumerState<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(profileRepositoryProvider).changePassword(
            widget.userId,
            newPassword: _next.text,
            currentPassword: widget.hasPassword ? _current.text : null,
          );
      ref.invalidate(myAccountProvider);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.hasPassword ? 'Contraseña actualizada' : 'Contraseña creada',
          ),
        ),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.hasPassword) ...[
            PasswordField(controller: _current, label: 'Contraseña actual'),
            const SizedBox(height: 12),
          ],
          PasswordField(
            controller: _next,
            label: 'Contraseña nueva',
            isNew: true,
            minLength: 8,
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _repeat,
            label: 'Repetir contraseña nueva',
            matchWith: _next,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          PrimarySubmitButton(
            label: widget.hasPassword
                ? 'Cambiar contraseña'
                : 'Crear contraseña',
            loading: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
