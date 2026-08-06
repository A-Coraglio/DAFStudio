import 'package:dio/dio.dart';

import 'sport_model.dart';

class SportsRepository {
  SportsRepository(this._dio);

  final Dio _dio;

  Future<List<Sport>> list() async {
    final res = await _dio.get<List<dynamic>>('/api/sports/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Sport.fromJson)
        .toList();
  }
}
