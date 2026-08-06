import 'game.dart';
import 'game_player.dart';

/// Slot semantics shared by the card slots row and the detail court board.
/// A game has `maxPlayers` slots; slots 0..homeSlots-1 are the home side
/// (Equipo A), the rest are away (Equipo B).
class GamePositions {
  /// Racket-sized games (pádel 4, tenis 2/4) render selectable slots right
  /// on the feed card; bigger rosters (F5, vóley, básquet) don't fit there
  /// and use the court board inside the detail screen instead.
  static bool showOnCard(Game g) => g.maxPlayers >= 2 && g.maxPlayers <= 4;

  static int homeSlots(int maxPlayers) => maxPlayers ~/ 2;

  static bool isHomeSlot(int maxPlayers, int position) =>
      position < homeSlots(maxPlayers);

  static String sideLabel(int maxPlayers, int position) =>
      isHomeSlot(maxPlayers, position) ? 'Equipo A' : 'Equipo B';

  /// position -> player, for players that picked a spot.
  static Map<int, GamePlayer> bySlot(List<GamePlayer> players) => {
    for (final p in players)
      if (p.position != null) p.position!: p,
  };

  /// Players that joined without picking a spot (matchmaking / legacy).
  static List<GamePlayer> unpositioned(List<GamePlayer> players) => [
    for (final p in players)
      if (p.position == null) p,
  ];
}
