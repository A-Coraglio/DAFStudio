import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
  const UsernameField({
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
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      decoration: const InputDecoration(labelText: 'Usuario'),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return 'Elegí un usuario';
        if (value.length < 3) return 'Mínimo 3 caracteres';
        return null;
      },
    );
  }
}
