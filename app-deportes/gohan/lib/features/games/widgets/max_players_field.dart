import 'package:flutter/material.dart';

class MaxPlayersField extends StatelessWidget {
  const MaxPlayersField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Cantidad de jugadores'),
      validator: (v) {
        final n = int.tryParse((v ?? '').trim());
        if (n == null) return 'Poné un número';
        if (n < 2) return 'Mínimo 2';
        if (n > 40) return 'Demasiado — ¿seguro?';
        return null;
      },
    );
  }
}
