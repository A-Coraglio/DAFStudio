import 'package:flutter/material.dart';

import 'game_datetime_picker.dart';
import 'game_level_picker.dart';
import 'game_name_field.dart';
import 'max_players_field.dart';

/// Field stack of the edit-game sheet: name, cupo, level, date (con "Quitar
/// fecha") and the optional "Quitar cancha" switch.
class EditGameFields extends StatelessWidget {
  const EditGameFields({
    super.key,
    required this.nameCtrl,
    required this.maxCtrl,
    required this.level,
    required this.onLevel,
    required this.at,
    required this.onAt,
    required this.hasCourt,
    required this.removeCourt,
    required this.onRemoveCourt,
  });

  final TextEditingController nameCtrl;
  final TextEditingController maxCtrl;
  final String? level;
  final ValueChanged<String?> onLevel;
  final DateTime? at;
  final ValueChanged<DateTime?> onAt;

  /// True when the game currently has a court — shows the remove switch.
  final bool hasCourt;
  final bool removeCourt;
  final ValueChanged<bool> onRemoveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameNameField(controller: nameCtrl),
        const SizedBox(height: 12),
        MaxPlayersField(controller: maxCtrl),
        const SizedBox(height: 12),
        GameLevelPicker(value: level, onChanged: onLevel),
        const SizedBox(height: 12),
        GameDateTimePicker(value: at, onChanged: onAt),
        if (at != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onAt(null),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Quitar fecha'),
            ),
          ),
        if (hasCourt)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Quitar cancha'),
            subtitle: const Text('El partido queda sin cancha asignada'),
            value: removeCourt,
            onChanged: onRemoveCourt,
          ),
      ],
    );
  }
}
