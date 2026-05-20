import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../data/auth_models.dart';
import '../providers/auth_providers.dart';
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
      final res = await ref.read(authRepositoryProvider).login(
            LoginRequest(
              email: _emailCtrl.text.trim(),
              password: _passCtrl.text,
            ),
          );
      await ref.read(sessionProvider.notifier).setToken(res.accessToken);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AuthHeader(
                    subtitle:
                        'Encontrá con quién jugar, en cualquier deporte.',
                  ),
                  EmailField(
                    controller: _emailCtrl,
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
                    onPressed: _loading ? null : () => context.go('/register'),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

