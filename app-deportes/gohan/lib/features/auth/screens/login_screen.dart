import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/debug_base_url_notice.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../../../core/errors/error_snackbar.dart';
import '../data/auth_models.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/email_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await ref
          .read(authRepositoryProvider)
          .login(
            LoginRequest(
              identifier: _emailCtrl.text.trim(),
              password: _passCtrl.text,
            ),
          );
      await ref
          .read(sessionProvider.notifier)
          .setToken(res.accessToken, refreshToken: res.refreshToken);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ingresar'),
        backgroundColor: Colors.transparent,
      ),
      body: AuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AuthHeader(
                        subtitle:
                            'Encontrá con quién jugar, en cualquier deporte.',
                      ),
                      EmailField(
                        controller: _emailCtrl,
                        label: 'Email o usuario',
                        requireEmail: false,
                        onSubmitted: (_) => _passFocus.requestFocus(),
                      ),
                      const SizedBox(height: 12),
                      PasswordField(
                        controller: _passCtrl,
                        focusNode: _passFocus,
                        onSubmitted: (_) => _loading ? null : _submit(),
                      ),
                      const SizedBox(height: 20),
                      PrimarySubmitButton(
                        label: 'Ingresar',
                        onPressed: _submit,
                        loading: _loading,
                      ),
                      const SizedBox(height: 12),
                      const AuthOrDivider(),
                      const SizedBox(height: 12),
                      GoogleSignInButton(disabled: _loading),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => context.go('/register'),
                        child: const Text('Crear cuenta'),
                      ),
                      const DebugBaseUrlNotice(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
