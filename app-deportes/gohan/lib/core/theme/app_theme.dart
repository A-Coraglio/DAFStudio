import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_schemes.dart';

/// Temas de la app — sistema "Club de barrio moderno": verde pino sobre
/// neutros cálidos (crema), dorado "hora dorada" como acento de energía,
/// Sora para títulos y números, Inter para cuerpo. Ver AppSchemes/AppColors.
class AppTheme {
  static ThemeData light() => _build(AppSchemes.light, AppColors.light);
  static ThemeData dark() => _build(AppSchemes.dark, AppColors.dark);

  static TextTheme _text(ColorScheme scheme) {
    final base = GoogleFonts.interTextTheme(
      ThemeData(colorScheme: scheme, useMaterial3: true).textTheme,
    );
    TextStyle? sora(TextStyle? s, FontWeight w, {double? spacing}) => s == null
        ? null
        : GoogleFonts.sora(textStyle: s, fontWeight: w, letterSpacing: spacing);
    return base.copyWith(
      headlineMedium: sora(base.headlineMedium, FontWeight.w700, spacing: -.5),
      headlineSmall: sora(base.headlineSmall, FontWeight.w700, spacing: -.5),
      titleLarge: sora(base.titleLarge, FontWeight.w700),
      titleMedium: sora(base.titleMedium, FontWeight.w600),
      // Eyebrows tipo "TU PRÓXIMO PARTIDO": chicos, pesados, con tracking.
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }

  static ThemeData _build(ColorScheme scheme, AppColors colors) {
    final text = _text(scheme);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: text,
      extensions: [colors],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        // Títulos protagonistas: más altos y en la display (Sora w700).
        toolbarHeight: 64,
        titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
      ),
      // minimumSize keeps a finite width on purpose: Size.fromHeight forces
      // width=infinity, which crashes any button placed inside a Row.
      // Full-width CTAs get their width from the layout (SizedBox/ListView).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: colors.accent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.onAccent
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
