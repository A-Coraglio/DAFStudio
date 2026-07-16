import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.label = 'Email',
    this.requireEmail = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  /// Field label. Login uses "Email o usuario"; register keeps "Email".
  final String label;

  /// When false the field accepts a username too (no `@` requirement) — used
  /// on the login screen where either identifier is valid.
  final bool requireEmail;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType:
          requireEmail ? TextInputType.emailAddress : TextInputType.text,
      autofillHints: requireEmail
          ? const [AutofillHints.email]
          : const [AutofillHints.username, AutofillHints.email],
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) {
          return requireEmail ? 'Ingresá tu email' : 'Ingresá tu email o usuario';
        }
        if (requireEmail && !value.contains('@')) return 'Email inválido';
        return null;
      },
    );
  }
}
