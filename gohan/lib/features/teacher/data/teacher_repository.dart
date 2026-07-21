import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'teacher_profile.dart';
import 'teacher_status.dart';

class TeacherRepository {
  TeacherRepository(this._dio);

  final Dio _dio;

  Future<TeacherStatus> myStatus() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/teachers/my-status/',
    );
    return TeacherStatus.fromJson(requireData(res));
  }

  /// Solicitud "quiero ser profe" — queda pendiente de un admin.
  Future<TeacherStatus> apply({
    required String bio,
    required double pricePerHour,
    int? experienceYears,
    required List<int> sportIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/teachers/apply/',
      data: {
        'bio': bio,
        'price_per_hour': pricePerHour,
        if (experienceYears != null) 'experience_years': experienceYears,
        'sport_ids': sportIds,
      },
    );
    return TeacherStatus.fromJson(requireData(res));
  }

  Future<TeacherProfile> updateMe({
    String? bio,
    double? pricePerHour,
    int? experienceYears,
    List<int>? sportIds,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/teachers/me/',
      data: {
        if (bio != null) 'bio': bio,
        if (pricePerHour != null) 'price_per_hour': pricePerHour,
        if (experienceYears != null) 'experience_years': experienceYears,
        if (sportIds != null) 'sport_ids': sportIds,
      },
    );
    return TeacherProfile.fromJson(requireData(res));
  }
}
