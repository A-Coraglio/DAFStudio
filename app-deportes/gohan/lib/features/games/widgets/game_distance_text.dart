import 'package:flutter/material.dart';

/// Compact "place pin + distance" label for a game card. Shows metres under
/// 1 km, otherwise one-decimal kilometres (Spanish comma).
class GameDistanceText extends StatelessWidget {
  const GameDistanceText({super.key, required this.distanceKm});

  final double distanceKm;

  String get _label {
    if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
    return '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.place_outlined, size: 16, color: style?.color),
        const SizedBox(width: 2),
        Text(_label, style: style),
      ],
    );
  }
}
