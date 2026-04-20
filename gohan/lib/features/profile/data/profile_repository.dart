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
