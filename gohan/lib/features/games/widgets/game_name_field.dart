import 'package:flutter/material.dart';

class GameNameField extends StatelessWidget {
  const GameNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nombre del partido',
        hintText: 'Ej: Fútbol 5 en la semana',
      ),
      textInputAction: TextInputAction.next,
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return 'Ponele un nombre al partido';
        if (value.length < 3) return 'Mínimo 3 caracteres';
        return null;
      },
    );
  }
}
