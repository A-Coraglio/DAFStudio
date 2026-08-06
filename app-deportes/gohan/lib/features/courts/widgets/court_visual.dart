import 'package:flutter/material.dart';

import '../../../core/format/sport_icons.dart';
import '../../../core/theme/app_colors.dart';

/// "Foto" de la cancha. La DB todavía no guarda imágenes, así que esto es
/// un visual de marca (gradiente + ícono del deporte) con el mismo layout
/// que tendrá la foto real — cuando exista `photo_url`, solo se reemplaza
/// el fondo por un `Image.network` con este mismo fallback.
class CourtVisual extends StatelessWidget {
  const CourtVisual({
    super.key,
    required this.sportName,
    this.isIndoor = false,
    this.height = 110,
  });

  final String? sportName;
  final bool isIndoor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: brandGradient(Theme.of(context).brightness),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              sportIcon(sportName),
              size: 44,
              color: Colors.white.withValues(alpha: .85),
            ),
          ),
          if (isIndoor)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Techada',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
