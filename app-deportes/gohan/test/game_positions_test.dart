import 'package:flutter_test/flutter_test.dart';
import 'package:gohan/features/games/data/game_player.dart';
import 'package:gohan/features/games/data/game_positions.dart';

GamePlayer gp(int playerId, {int? position}) => GamePlayer(
  gameId: 1,
  playerId: playerId,
  position: position,
  createdAt: DateTime(2026, 7, 21),
  firstName: 'P$playerId',
  lastName: null,
  level: null,
  rankingPoints: 1000,
  avatarUrl: null,
);

void main() {
  group('GamePositions', () {
    test('homeSlots es la mitad del cupo', () {
      expect(GamePositions.homeSlots(4), 2);
      expect(GamePositions.homeSlots(10), 5);
      expect(GamePositions.homeSlots(2), 1);
    });

    test('sideLabel: primera mitad Equipo A, resto Equipo B', () {
      expect(GamePositions.sideLabel(4, 0), 'Equipo A');
      expect(GamePositions.sideLabel(4, 1), 'Equipo A');
      expect(GamePositions.sideLabel(4, 2), 'Equipo B');
      expect(GamePositions.sideLabel(10, 9), 'Equipo B');
    });

    test('bySlot indexa solo a los que eligieron posición', () {
      final players = [gp(1, position: 0), gp(2), gp(3, position: 3)];
      final bySlot = GamePositions.bySlot(players);
      expect(bySlot.length, 2);
      expect(bySlot[0]!.playerId, 1);
      expect(bySlot[3]!.playerId, 3);
      expect(bySlot[1], isNull);
    });

    test('unpositioned lista a los que entraron sin elegir', () {
      final players = [gp(1, position: 0), gp(2), gp(3)];
      final libres = GamePositions.unpositioned(players);
      expect(libres.map((p) => p.playerId), [2, 3]);
    });
  });
}
