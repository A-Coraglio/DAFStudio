import 'package:flutter/material.dart';

/// Segmented button to pick between the two user-facing modes. Matchmaking
/// is omitted on purpose — it's created by the quick-match queue, not by a
/// human filling a form.
class GameModePicker extends StatelessWidget {
  const GameModePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'casual',
          icon: Icon(Icons.sentiment_satisfied),
          label: Text('Casual'),
        ),
        ButtonSegment(
          value: 'competitive',
          icon: Icon(Icons.military_tech),
          label: Text('Competitivo'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
