import 'package:flutter/material.dart';

/// Game title field. When a [suggestion] is provided (built from sport +
/// date), the field becomes optional — leaving it empty uses the suggestion.
class GameNameField extends StatelessWidget {
  const GameNameField({
    super.key,
    required this.controller,
    this.suggestion,
  });

  final TextEditingController controller;
  final String? suggestion;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nombre del partido',
        hintText: suggestion ?? 'Ej: Fútbol 5 en la semana',
        helperText:
            suggestion != null ? 'Dejalo vacío para usar la sugerencia' : null,
      ),
      textInputAction: TextInputAction.next,
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) {
          return suggestion == null ? 'Ponele un nombre al partido' : null;
        }
        if (value.length < 3) return 'Mínimo 3 caracteres';
        return null;
      },
    );
  }
}
