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
