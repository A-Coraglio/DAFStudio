import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/http/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../data/auth_models.dart';
import '../providers/auth_providers.dart';

/// "Continuar con Google" button. Runs the native Google Sign-In flow,
/// posts the id_token to the backend, persists the JWT and routes home.
/// `disabled` is honored so the parent can lock the UI during an in-flight
/// email/password submit.
class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({super.key, this.disabled = false});

  final bool disabled;

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _busy = false;

  Future<void> _onPressed() async {
    setState(() => _busy = true);
    try {
      final account = await GoogleSignIn().signIn();
      if (account == null) return; // user cancelled
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw const _MissingIdTokenException();
      }
      final res = await ref
          .read(authRepositoryProvider)
          .loginWithGoogle(GoogleLoginRequest(idToken: idToken));
      await ref.read(sessionProvider.notifier).setToken(res.accessToken);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      _snack(dioErrorMessage(e));
    } on _MissingIdTokenException {
      _snack('Google no devolvió un id_token. Revisá la config OAuth.');
    } catch (e) {
      _snack('No se pudo iniciar sesión con Google: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled || _busy;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: disabled ? null : _onPressed,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : SvgPicture.asset('assets/google_g.svg', width: 18, height: 18),
        label: const Text('Continuar con Google'),
      ),
    );
  }
}

class _MissingIdTokenException implements Exception {
  const _MissingIdTokenException();
}
