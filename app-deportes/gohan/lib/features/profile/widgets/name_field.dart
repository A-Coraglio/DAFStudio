import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return '$label requerido';
        if (value.length < 2) return 'Mínimo 2 caracteres';
        return null;
      },
    );
  }
}
