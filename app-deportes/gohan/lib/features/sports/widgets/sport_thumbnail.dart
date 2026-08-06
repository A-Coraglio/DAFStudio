import 'package:flutter/material.dart';

import '../../../core/format/sport_icons.dart';

/// A small branded "miniatura" for a sport: the sport's icon over a per-sport
/// gradient. The DB doesn't store sport images yet, so this is the generated
/// stand-in — same idea as `CourtVisual`. If real images arrive later, swap
/// the gradient `Container` for an `Image` and keep this as the fallback.
///
/// Used both in the home sport selector and on every game card so the selected
/// sport and its games share one consistent visual.
class SportThumbnail extends StatelessWidget {
  const SportThumbnail({
    super.key,
    required this.sportName,
    this.size = 44,
    this.borderRadius = 12,
    this.iconScale = 0.55,
  });

  final String? sportName;
  final double size;
  final double borderRadius;

  /// Icon size as a fraction of [size]. Smaller looks better on big tiles.
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: sportGradient(sportName),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        sportIcon(sportName),
        size: size * iconScale,
        color: Colors.white.withValues(alpha: .95),
      ),
    );
  }
}
