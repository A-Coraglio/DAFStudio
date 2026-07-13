import 'package:dio/dio.dart';

import 'club.dart';
import 'court.dart';

class CourtsRepository {
  CourtsRepository(this._dio);

  final Dio _dio;

  /// `GET /api/courts/` with the filters exposed by the backend. Nulls are
  /// skipped. Already visibility-filtered server-side: users only get club
  /// courts + their own privates.
  Future<List<Court>> list({
    int? sportId,
    int? clubId,
    double? nearLat,
    double? nearLon,
    double? radiusKm,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/courts/',
      queryParameters: {
        if (sportId != null) 'sport_id': sportId,
        if (clubId != null) 'club_id': clubId,
        if (nearLat != null) 'near_lat': nearLat,
        if (nearLon != null) 'near_lon': nearLon,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Court.fromJson)
        .toList();
  }

  Future<Court> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/courts/$id/');
    return Court.fromJson(res.data!);
  }

  /// `GET /api/clubs/` — used to group club courts by venue in the picker.
  Future<List<Club>> listClubs() async {
    final res = await _dio.get<List<dynamic>>('/api/clubs/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Club.fromJson)
        .toList();
  }
}
