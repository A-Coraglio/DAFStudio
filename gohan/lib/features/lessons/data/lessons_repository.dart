import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'busy_slot.dart';
import 'lesson_model.dart';

class LessonsRepository {
  LessonsRepository(this._dio);

  final Dio _dio;

  /// The caller's lessons: upcoming first, then past ones.
  Future<List<Lesson>> mine() async {
    final res = await _dio.get<List<dynamic>>('/api/lessons/mine/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Lesson.fromJson)
        .toList();
  }

  /// Book a lesson with a teacher. Times follow the scheduled_at convention:
  /// user-local, serialized naive (no offset).
  Future<Lesson> book({
    required int teacherId,
    required DateTime start,
    required DateTime end,
    int? sportId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/lessons/',
      data: {
        'teacher_id': teacherId,
        if (sportId != null) 'sport_id': sportId,
        'start_time': start.toIso8601String(),
        'end_time': end.toIso8601String(),
      },
    );
    return Lesson.fromJson(requireData(res));
  }

  /// Upcoming occupied slots of a teacher's agenda (no student data).
  Future<List<BusySlot>> busy(int teacherId) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/lessons/busy/',
      queryParameters: {'teacher_id': teacherId},
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(BusySlot.fromJson)
        .toList();
  }

  Future<Lesson> cancel(int lessonId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/lessons/$lessonId/cancel/',
    );
    return Lesson.fromJson(requireData(res));
  }
}
