import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'tournament_model.dart';
import 'tournament_participant.dart';

class TournamentsRepository {
  TournamentsRepository(this._dio);

  final Dio _dio;

  /// Personalised strip for the home carousel (sport + level + distance).
  Future<List<Tournament>> recommended({
    double? nearLat,
    double? nearLon,
    int? sportId,
    int limit = 8,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/tournaments/recommended/',
      queryParameters: {
        'limit': limit,
        if (nearLat != null) 'near_lat': nearLat,
        if (nearLon != null) 'near_lon': nearLon,
        if (sportId != null) 'sport_id': sportId,
      },
    );
    return _parse(res.data);
  }

  /// General search/list for the tournaments screen.
  Future<List<Tournament>> list({
    int? sportId,
    String? level,
    String? status,
    double? nearLat,
    double? nearLon,
    double? radiusKm,
    int limit = 50,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/tournaments/',
      queryParameters: {
        'limit': limit,
        if (sportId != null) 'sport_id': sportId,
        if (level != null) 'level': level,
        if (status != null) 'status': status,
        if (nearLat != null) 'near_lat': nearLat,
        if (nearLon != null) 'near_lon': nearLon,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
    );
    return _parse(res.data);
  }

  Future<Tournament> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/tournaments/$id/');
    return Tournament.fromJson(requireData(res));
  }

  Future<List<TournamentParticipant>> participants(int id) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/tournaments/$id/participants/',
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(TournamentParticipant.fromJson)
        .toList();
  }

  /// Enroll the current user. Returns the updated tournament (fresh count).
  Future<Tournament> join(int id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tournaments/$id/join/',
    );
    return Tournament.fromJson(requireData(res));
  }

  /// Unenroll the current user (only while the tournament is upcoming).
  Future<Tournament> leave(int id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tournaments/$id/leave/',
    );
    return Tournament.fromJson(requireData(res));
  }

  List<Tournament> _parse(List<dynamic>? data) => (data ?? const [])
      .cast<Map<String, dynamic>>()
      .map(Tournament.fromJson)
      .toList();
}
