import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'class_model.dart';

class ClassesRepository {
  ClassesRepository(this._dio);

  final Dio _dio;

  /// Personalised strip for the home carousel (favorite sport + distance).
  Future<List<ClassOffering>> recommended({
    double? nearLat,
    double? nearLon,
    int? sportId,
    int limit = 8,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/classes/recommended/',
      queryParameters: {
        'limit': limit,
        if (nearLat != null) 'near_lat': nearLat,
        if (nearLon != null) 'near_lon': nearLon,
        if (sportId != null) 'sport_id': sportId,
      },
    );
    return _parse(res.data);
  }

  /// General search/list for the classes screen.
  Future<List<ClassOffering>> list({
    int? sportId,
    double? maxPrice,
    double? nearLat,
    double? nearLon,
    double? radiusKm,
    int limit = 50,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/classes/',
      queryParameters: {
        'limit': limit,
        if (sportId != null) 'sport_id': sportId,
        if (maxPrice != null) 'max_price': maxPrice,
        if (nearLat != null) 'near_lat': nearLat,
        if (nearLon != null) 'near_lon': nearLon,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
    );
    return _parse(res.data);
  }

  Future<ClassOffering> getById(int teacherId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/classes/$teacherId/');
    return ClassOffering.fromJson(requireData(res));
  }

  List<ClassOffering> _parse(List<dynamic>? data) => (data ?? const [])
      .cast<Map<String, dynamic>>()
      .map(ClassOffering.fromJson)
      .toList();
}
