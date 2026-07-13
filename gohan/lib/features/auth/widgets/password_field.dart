import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.minLength,
    this.label = 'Contraseña',
    this.isNew = false,
    this.matchWith,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final int? minLength;
  final String label;
  /// True on register — tells password managers to offer a generated one.
  final bool isNew;
  /// When set, this field must match the other controller ("repetir
  /// contraseña"); the length rule is skipped.
  final TextEditingController? matchWith;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  String? _validate(String? v) {
    final value = v ?? '';
    if (widget.matchWith != null) {
      return value == widget.matchWith!.text
          ? null
          : 'Las contraseñas no coinciden';
    }
    if (value.isEmpty) return 'Ingresá tu contraseña';
    if (widget.minLength != null && value.length < widget.minLength!) {
      return 'Mínimo ${widget.minLength} caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      autofillHints: [
        widget.isNew ? AutofillHints.newPassword : AutofillHints.password,
      ],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: _validate,
    );
  }
}
