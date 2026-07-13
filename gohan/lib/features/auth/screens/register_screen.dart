import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../data/auth_models.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/email_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_field.dart';
import '../widgets/username_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        RegisterRequest(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      );
      // Auto-login after register, then route to onboarding. The router's
      // profile-completion guard will handle /complete-profile vs /home.
      final login = await repo.login(
        LoginRequest(email: _emailCtrl.text.trim(), password: _passCtrl.text),
      );
      await ref.read(sessionProvider.notifier).setToken(login.accessToken);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dioErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
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
                      UsernameField(controller: _usernameCtrl),
                      const SizedBox(height: 12),
                      EmailField(controller: _emailCtrl),
                      const SizedBox(height: 12),
                      PasswordField(
                        controller: _passCtrl,
                        minLength: 6,
                        isNew: true,
                      ),
                      const SizedBox(height: 12),
                      PasswordField(
                        controller: _pass2Ctrl,
                        label: 'Repetir contraseña',
                        isNew: true,
                        matchWith: _passCtrl,
                        onSubmitted: (_) => _loading ? null : _submit(),
                      ),
                      const SizedBox(height: 20),
                      PrimarySubmitButton(
                        label: 'Crear cuenta',
                        onPressed: _submit,
                        loading: _loading,
                      ),
                      const SizedBox(height: 12),
                      const AuthOrDivider(),
                      const SizedBox(height: 12),
                      GoogleSignInButton(disabled: _loading),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loading ? null : () => context.go('/login'),
                        child: const Text('Ya tengo cuenta'),
                      ),
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
