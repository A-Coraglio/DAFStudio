import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'create_game_request.dart';
import 'game.dart';
import 'game_player.dart';

class GamesRepository {
  GamesRepository(this._dio);

  final Dio _dio;

  /// Lists games with the filters exposed by `GET /api/games/`. All params
  /// are optional — nulls are skipped so the backend applies no filter for
  /// that dimension.
  Future<List<Game>> list({
    int? sportId,
    String? mode,
    String? level,
    String? status,
    int? organizerId,
    DateTime? scheduledAfter,
    DateTime? scheduledBefore,
    double? nearLat,
    double? nearLon,
    double? radiusKm,
    int? courtId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/games/',
      queryParameters: {
        if (courtId != null) 'court_id': courtId,
        if (sportId != null) 'sport_id': sportId,
        if (mode != null) 'mode': mode,
        if (level != null) 'level': level,
        if (status != null) 'status': status,
        if (organizerId != null) 'organizer_id': organizerId,
        if (scheduledAfter != null)
          'scheduled_after': scheduledAfter.toIso8601String(),
        if (scheduledBefore != null)
          'scheduled_before': scheduledBefore.toIso8601String(),
        // near_lat/near_lon alone → distance only; with radius_km → filter.
        if (nearLat != null) 'near_lat': nearLat,
        if (nearLon != null) 'near_lon': nearLon,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Game.fromJson)
        .toList();
  }

  /// Organizer-only partial update (PUT /api/games/{id}/). Nulls are
  /// skipped — only the provided fields change.
  Future<Game> update(
    int id, {
    String? name,
    int? maxPlayers,
    String? level,
    DateTime? scheduledAt,
    String? status,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/games/$id/',
      data: {
        if (name != null) 'name': name,
        if (maxPlayers != null) 'max_players': maxPlayers,
        if (level != null) 'level': level,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
        if (status != null) 'status': status,
      },
    );
    return Game.fromJson(requireData(res));
  }

  Future<Game> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/games/$id/');
    return Game.fromJson(requireData(res));
  }

  Future<List<GamePlayer>> listPlayers(int gameId) async {
    final res = await _dio.get<List<dynamic>>('/api/games/$gameId/players/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(GamePlayer.fromJson)
        .toList();
  }

  /// [position] is the chosen slot (0..max_players-1, first half = home
  /// side); omit it to join without picking a spot.
  Future<Game> join(int gameId, {int? position}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/games/$gameId/join/',
      data: {if (position != null) 'position': position},
    );
    return Game.fromJson(requireData(res));
  }

  /// Re-positions an already-joined player to [position] (0..max_players-1).
  Future<Game> move(int gameId, {required int position}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/games/$gameId/move/',
      data: {'position': position},
    );
    return Game.fromJson(requireData(res));
  }

  Future<Game> leave(int gameId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/games/$gameId/leave/',
    );
    return Game.fromJson(requireData(res));
  }

  Future<Game> create(CreateGameRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/games/',
      data: req.toJson(),
    );
    return Game.fromJson(requireData(res));
  }

  /// Reports a result. Single-score sports pass [home]/[away]; set-based
  /// sports pass [sets] (a list of per-set scores) and the backend derives the
  /// sets-won winner.
  Future<Game> reportResult(
    int gameId, {
    int? home,
    int? away,
    List<({int home, int away})>? sets,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/games/$gameId/report-result/',
      data: {
        if (home != null) 'reported_home': home,
        if (away != null) 'reported_away': away,
        if (sets != null)
          'sets': [
            for (final s in sets) {'home': s.home, 'away': s.away},
          ],
      },
    );
    return Game.fromJson(requireData(res));
  }
}
