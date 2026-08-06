import 'package:flutter/material.dart';

const _levels = [
  (value: null, label: 'Cualquiera'),
  (value: 'beginner', label: 'Principiante'),
  (value: 'intermediate', label: 'Intermedio'),
  (value: 'advanced', label: 'Avanzado'),
];

/// Optional level restriction for a game. Null means "sin requisito".
class GameLevelPicker extends StatelessWidget {
  const GameLevelPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Nivel (opcional)'),
      items: [
        for (final l in _levels)
          DropdownMenuItem<String?>(value: l.value, child: Text(l.label)),
      ],
      onChanged: onChanged,
    );
  }
}
