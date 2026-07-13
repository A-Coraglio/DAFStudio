import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return 'Ingresá tu email';
        if (!value.contains('@')) return 'Email inválido';
        return null;
      },
    );
  }
}
