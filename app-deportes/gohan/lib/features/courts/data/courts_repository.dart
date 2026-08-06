import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
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
    return Court.fromJson(requireData(res));
  }

  /// `GET /api/clubs/` — used to group club courts by venue in the picker.
  Future<List<Club>> listClubs() async {
    final res = await _dio.get<List<dynamic>>('/api/clubs/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Club.fromJson)
        .toList();
  }

  /// Clubes de los que soy dueño/organizador — gatea el panel "Mi club".
  Future<List<Club>> myClubs() async {
    final res = await _dio.get<List<dynamic>>('/api/clubs/mine/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Club.fromJson)
        .toList();
  }

  /// Alta de cancha dentro de un club propio (403 si no sos el dueño).
  Future<Court> createClubCourt(
    int clubId, {
    required String name,
    required int sportId,
    required double pricePerHour,
    bool isIndoor = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/clubs/$clubId/courts/',
      data: {
        'name': name,
        'sport_id': sportId,
        'price_per_hour': pricePerHour,
        'is_indoor': isIndoor,
      },
    );
    return Court.fromJson(requireData(res));
  }
}
