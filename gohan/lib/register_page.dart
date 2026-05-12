import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _pass2Focus = FocusNode();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _pass2Focus.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _doRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      if (res.session != null) {
        // Email confirmation desactivado: ya quedó logueado.
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Email confirmation activado: usuario creado pero debe verificar.
        _snack('Cuenta creada. Revisá tu email para confirmarla.');
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('No se pudo crear la cuenta. Probá de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passFocus);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Ingresá tu email';
                      if (!value.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    obscureText: _obscure,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_pass2Focus);
                    },
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    validator: (v) {
                      if ((v ?? '').isEmpty) return 'Ingresá una contraseña';
                      if ((v ?? '').length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass2Ctrl,
                    focusNode: _pass2Focus,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_loading) _doRegister();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Repetir contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if ((v ?? '').isEmpty) return 'Repetí la contraseña';
                      if (v != _passCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _doRegister,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear cuenta'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Ya tengo cuenta — Iniciar sesión'),
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
