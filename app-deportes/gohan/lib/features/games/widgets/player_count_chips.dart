import 'package:flutter/material.dart';

/// Roster-size selector: one chip per valid count for the sport, plus an
/// "Otro" chip that reveals a numeric field for edge cases. Replaces the
/// free-text max-players field — el default ya viene elegido por deporte.
class PlayerCountChips extends StatefulWidget {
  const PlayerCountChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<int> options;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<PlayerCountChips> createState() => _PlayerCountChipsState();
}

class _PlayerCountChipsState extends State<PlayerCountChips> {
  bool _custom = false;
  late final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCustom = _custom || !widget.options.contains(widget.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jugadores', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final n in widget.options)
              ChoiceChip(
                label: Text('$n'),
                selected: !showCustom && widget.value == n,
                onSelected: (_) {
                  setState(() => _custom = false);
                  widget.onChanged(n);
                },
              ),
            ChoiceChip(
              label: const Text('Otro'),
              selected: showCustom,
              onSelected: (_) => setState(() => _custom = true),
            ),
          ],
        ),
        if (showCustom) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: TextFormField(
              controller: _customCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n < 2) return 'Mínimo 2';
                return null;
              },
              onChanged: (v) {
                final n = int.tryParse(v.trim());
                if (n != null && n >= 2) widget.onChanged(n);
              },
            ),
          ),
        ],
      ],
    );
  }
}
