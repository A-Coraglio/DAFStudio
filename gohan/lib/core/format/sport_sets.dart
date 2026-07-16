/// Set-based sports report several sets (pádel best-of-3, tenis up to 5,
/// vóley up to 5). Single-score sports (fútbol, básquet) return 1.
int maxSetsForSport(String? name) {
  final n = (name ?? '').toLowerCase();
  if (n.contains('pádel') || n.contains('padel')) return 3;
  if (n.contains('tenis') || n.contains('tennis')) return 5;
  if (n.contains('vóley') || n.contains('voley') || n.contains('volley')) {
    return 5;
  }
  if (n.contains('ping') || n.contains('squash')) return 5;
  return 1;
}

/// True when a sport is played by sets and the report UI should collect
/// per-set scores instead of a single scoreline.
bool isSetSport(String? name) => maxSetsForSport(name) > 1;
