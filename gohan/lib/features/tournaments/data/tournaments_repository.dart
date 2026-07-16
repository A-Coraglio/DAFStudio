import 'package:dio/dio.dart';

import 'tournament_model.dart';

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
    return Tournament.fromJson(res.data!);
  }

  List<Tournament> _parse(List<dynamic>? data) => (data ?? const [])
      .cast<Map<String, dynamic>>()
      .map(Tournament.fromJson)
      .toList();
}
