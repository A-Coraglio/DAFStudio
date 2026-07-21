// Spanish labels for the enum-ish strings the backend stores in English.
// Every screen renders levels and modes through these helpers so the raw
// values never leak into the UI.

String levelLabel(String? level) => switch (level) {
  'beginner' => 'Principiante',
  'intermediate' => 'Intermedio',
  'advanced' => 'Avanzado',
  null => 'Sin definir',
  final other => other,
};

String modeLabel(String mode) => switch (mode) {
  'casual' => 'Casual',
  'competitive' => 'Competitivo',
  'matchmaking' => 'Matchmaking',
  final other => other,
};

String tournamentStatusLabel(String status) => switch (status) {
  'upcoming' => 'Inscripción abierta',
  'ongoing' => 'En juego',
  'finished' => 'Finalizado',
  final other => other,
};

String lessonStatusLabel(String status) => switch (status) {
  'pending' => 'Pendiente',
  'confirmed' => 'Confirmada',
  'cancelled' => 'Cancelada',
  final other => other,
};

/// "a 2,3 km" style distance label, or null when there's no distance to show.
String? distanceLabel(double? km) {
  if (km == null) return null;
  if (km < 1) return 'a ${(km * 1000).round()} m';
  final rounded =
      km < 10 ? km.toStringAsFixed(1).replaceAll('.', ',') : '${km.round()}';
  return 'a $rounded km';
}

/// "12 jul" style short date (day + abbreviated month, Spanish).
String shortDate(DateTime d) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${d.day} ${months[d.month - 1]}';
}
