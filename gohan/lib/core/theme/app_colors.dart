import 'package:flutter/material.dart';

/// Colores de marca fuera del ColorScheme M3 — dirección "Club de barrio
/// moderno": el acento de energía es el dorado "hora dorada" (#FFC24B) y
/// los semánticos win/lose/draw. Los widgets los leen con
/// `Theme.of(context).extension<AppColors>()!`.
///
/// Regla del acento: SOLO para energía/acción-ahora (tab activa, "Jugar ya",
/// badge competitivo, matchmaking urgente, celebración). Nunca superficies
/// grandes ni texto largo.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.onAccent,
    required this.win,
    required this.winContainer,
    required this.onWinContainer,
    required this.lose,
    required this.loseContainer,
    required this.onLoseContainer,
    required this.draw,
    required this.drawContainer,
    required this.onDrawContainer,
  });

  final Color accent, onAccent;
  final Color win, winContainer, onWinContainer;
  final Color lose, loseContainer, onLoseContainer;
  final Color draw, drawContainer, onDrawContainer;

  static const light = AppColors(
    accent: Color(0xFFFFC24B),
    onAccent: Color(0xFF3D2E00),
    win: Color(0xFF157F3D),
    winContainer: Color(0xFFD9F0DC),
    onWinContainer: Color(0xFF0E5A2C),
    lose: Color(0xFFB3362E),
    loseContainer: Color(0xFFF8DAD2),
    onLoseContainer: Color(0xFF7C221C),
    draw: Color(0xFF8A5A00),
    drawContainer: Color(0xFFF7E9C4),
    onDrawContainer: Color(0xFF8A5A00),
  );

  static const dark = AppColors(
    accent: Color(0xFFFFC24B),
    onAccent: Color(0xFF3D2E00),
    win: Color(0xFF6FD69A),
    winContainer: Color(0xFF17351F),
    onWinContainer: Color(0xFF6FD69A),
    lose: Color(0xFFFF9284),
    loseContainer: Color(0xFF45211B),
    onLoseContainer: Color(0xFFFF9284),
    draw: Color(0xFFF2C14E),
    drawContainer: Color(0xFF3A2E10),
    onDrawContainer: Color(0xFFF2C14E),
  );

  @override
  ThemeExtension<AppColors> copyWith() => this;

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) => t < .5 ? this : (other ?? this);
}

/// Gradiente de marca (pino profundo) para los momentos hero: next-game,
/// carnet de perfil, tile del auth header. Fijo por brillo a propósito —
/// es marca, no un container M3 más.
List<Color> brandGradient(Brightness brightness) =>
    brightness == Brightness.dark
    ? const [Color(0xFF24473B), Color(0xFF14201C)]
    : const [Color(0xFF1E4D40), Color(0xFF12332A)];

/// Tinte suave para fondos degradados (home, auth) que funde al surface.
Color brandTint(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFF1B2A23)
    : const Color(0xFFE7EEDF);

/// Escala de radios de la app — un solo lugar, nada de números mágicos.
abstract final class AppRadius {
  static const xs = 8.0; // skeletons, mini elementos
  static const input = 12.0; // campos de texto
  static const tile = 16.0; // tiles, banners
  static const card = 20.0; // cards
}
