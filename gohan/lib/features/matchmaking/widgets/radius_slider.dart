import 'package:flutter/material.dart';

/// Slider 1–50 km with a live label above it. Bigger radius = faster match
/// but further venues — the usual CS-style tradeoff.
class RadiusSlider extends StatelessWidget {
  const RadiusSlider({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Radio máximo', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              '${value.round()} km',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Slider(
          min: 1,
          max: 50,
          divisions: 49,
          value: value,
          label: '${value.round()} km',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
