import '../../sports/data/sport_model.dart';

/// Roster sizes that make sense per sport (matched by display name) and the
/// standard default. Ej.: tenis se juega de 2 o 4, arrancando en singles;
/// pádel casi siempre 4. Deportes no mapeados caen al estándar derivado de
/// `max_players_per_team` del backend, con alternativas de equipo reducido.
({List<int> options, int standard}) playerCountOptions(Sport sport) {
  final n = sport.name.toLowerCase();
  if (n.contains('pádel') || n.contains('padel')) {
    return (options: [2, 4], standard: 4);
  }
  if (n.contains('tenis') || n.contains('tennis') || n.contains('ping')) {
    return (options: [2, 4], standard: 2);
  }
  if (n.contains('fút') || n.contains('fut') || n.contains('soccer')) {
    if (n.contains('11')) return (options: [22], standard: 22);
    if (n.contains('7')) return (options: [14], standard: 14);
    if (n.contains('5')) return (options: [10], standard: 10);
    return (options: [10, 14, 22], standard: 10);
  }
  if (n.contains('básquet') || n.contains('basquet') || n.contains('basket')) {
    return (options: [2, 6, 10], standard: 10);
  }
  if (n.contains('vóley') || n.contains('voley') || n.contains('volley')) {
    return (options: [4, 8, 12], standard: 12);
  }
  final standard = sport.maxPlayersPerTeam * 2;
  return (options: [standard], standard: standard);
}
