import 'package:dio/dio.dart';

import 'player_profile.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<PlayerProfile> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/players/me/');
    return PlayerProfile.fromJson(res.data!);
  }

  Future<PlayerProfile> updateMyProfile(UpdatePlayerRequest req) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/players/me/',
      data: req.toJson(),
    );
    return PlayerProfile.fromJson(res.data!);
  }
}
