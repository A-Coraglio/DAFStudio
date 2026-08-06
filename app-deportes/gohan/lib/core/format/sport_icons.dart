import 'package:flutter/material.dart';

/// Best-effort icon for a sport by its (Spanish) display name. Falls back to
/// a generic sports icon — new sports keep working without code changes.
IconData sportIcon(String? name) {
  final n = (name ?? '').toLowerCase();
  if (n.contains('fút') || n.contains('fut') || n.contains('soccer')) {
    return Icons.sports_soccer;
  }
  if (n.contains('pádel') ||
      n.contains('padel') ||
      n.contains('tenis') ||
      n.contains('tennis') ||
      n.contains('ping') ||
      n.contains('squash')) {
    return Icons.sports_tennis;
  }
  if (n.contains('básquet') || n.contains('basquet') || n.contains('basket')) {
    return Icons.sports_basketball;
  }
  if (n.contains('vóley') || n.contains('voley') || n.contains('volley')) {
    return Icons.sports_volleyball;
  }
  if (n.contains('hockey')) return Icons.sports_hockey;
  if (n.contains('rugby')) return Icons.sports_rugby;
  if (n.contains('golf')) return Icons.golf_course;
  if (n.contains('nataci') || n.contains('swim')) return Icons.pool;
  if (n.contains('run') || n.contains('correr') || n.contains('atlet')) {
    return Icons.directions_run;
  }
  if (n.contains('cicli') || n.contains('bici')) return Icons.directions_bike;
  if (n.contains('box') || n.contains('mma')) return Icons.sports_mma;
  if (n.contains('handbol') || n.contains('handball')) {
    return Icons.sports_handball;
  }
  return Icons.sports;
}

/// Per-sport gradient for the generated sport thumbnail (see `SportThumbnail`).
/// Distinct hues so each sport reads differently at a glance; falls back to a
/// neutral slate for unmapped sports so new ones still look intentional.
List<Color> sportGradient(String? name) {
  final n = (name ?? '').toLowerCase();
  if (n.contains('fút') || n.contains('fut') || n.contains('soccer')) {
    return const [Color(0xFF2E7D32), Color(0xFF1B5E20)]; // césped
  }
  if (n.contains('pádel') || n.contains('padel')) {
    return const [Color(0xFF17A2A0), Color(0xFF0B6E6C)]; // teal (el estrella)
  }
  if (n.contains('tenis') || n.contains('tennis') || n.contains('ping')) {
    return const [Color(0xFF9CCC65), Color(0xFF558B2F)]; // lima
  }
  if (n.contains('squash')) {
    return const [Color(0xFF26A69A), Color(0xFF00695C)];
  }
  if (n.contains('básquet') || n.contains('basquet') || n.contains('basket')) {
    return const [Color(0xFFF57C00), Color(0xFFE65100)]; // naranja
  }
  if (n.contains('vóley') || n.contains('voley') || n.contains('volley')) {
    return const [Color(0xFF5C6BC0), Color(0xFF303F9F)]; // índigo
  }
  if (n.contains('hockey')) return const [Color(0xFF00838F), Color(0xFF006064)];
  if (n.contains('rugby')) return const [Color(0xFF6D4C41), Color(0xFF4E342E)];
  if (n.contains('golf')) return const [Color(0xFF43A047), Color(0xFF2E7D32)];
  if (n.contains('nataci') || n.contains('swim')) {
    return const [Color(0xFF039BE5), Color(0xFF0277BD)];
  }
  if (n.contains('cicli') || n.contains('bici')) {
    return const [Color(0xFFEF6C00), Color(0xFFBF360C)];
  }
  if (n.contains('box') || n.contains('mma')) {
    return const [Color(0xFFC62828), Color(0xFF8E0000)];
  }
  return const [Color(0xFF546E7A), Color(0xFF37474F)]; // pizarra (fallback)
}
