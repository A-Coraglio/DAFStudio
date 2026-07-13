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
