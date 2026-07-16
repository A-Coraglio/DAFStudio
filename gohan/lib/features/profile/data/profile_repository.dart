import 'package:dio/dio.dart';

import '../../games/data/game.dart';
import 'player_profile.dart';
import 'player_stats.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<PlayerProfile> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/players/me/');
    return PlayerProfile.fromJson(res.data!);
  }

  /// Public profile of any player by id — backs the `/players/:id` screen.
  Future<PlayerProfile> getPlayer(int playerId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/players/$playerId/');
    return PlayerProfile.fromJson(res.data!);
  }

  /// Personal history feed. Each Game is enriched with `outcome` + `teamSide`.
  Future<List<Game>> getMyGames({
    String? status,
    String? mode,
    int limit = 30,
    int offset = 0,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/players/me/games/',
      queryParameters: {
        if (status != null) 'status': status,
        if (mode != null) 'mode': mode,
        'limit': limit,
        'offset': offset,
      },
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Game.fromJson)
        .toList(growable: false);
  }

  Future<PlayerStats> getMyStats({int? sportId}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/players/me/stats/',
      queryParameters: {if (sportId != null) 'sport_id': sportId},
    );
    return PlayerStats.fromJson(res.data!);
  }

  /// Public W/L/D stats of any player — backs the public profile screen.
  Future<PlayerStats> getPlayerStats(int playerId, {int? sportId}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/players/$playerId/stats/',
      queryParameters: {if (sportId != null) 'sport_id': sportId},
    );
    return PlayerStats.fromJson(res.data!);
  }

  /// Public recent history of any player (outcomes from their perspective).
  Future<List<Game>> getPlayerGames(int playerId, {int limit = 5}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/players/$playerId/games/',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Game.fromJson)
        .toList(growable: false);
  }

  /// Discovery feed. Backend excludes the caller from the results.
  Future<List<PlayerProfile>> searchPlayers({
    String? query,
    int? sportId,
    String? level,
    int limit = 30,
    int offset = 0,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/players/',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (sportId != null) 'sport_id': sportId,
        if (level != null) 'level': level,
        'limit': limit,
        'offset': offset,
      },
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PlayerProfile.fromJson)
        .toList(growable: false);
  }

  Future<PlayerProfile> updateMyProfile(UpdatePlayerRequest req) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/players/me/',
      data: req.toJson(),
    );
    return PlayerProfile.fromJson(res.data!);
  }

  /// Uploads a new avatar via multipart. `bytes` is the raw image bytes;
  /// `filename` is only used for the extension check on the backend.
  Future<PlayerProfile> uploadAvatar({
    required List<int> bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/players/me/avatar/',
      data: form,
    );
    return PlayerProfile.fromJson(res.data!);
  }
}
