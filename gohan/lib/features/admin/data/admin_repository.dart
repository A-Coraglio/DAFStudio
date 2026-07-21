import 'package:dio/dio.dart';

import 'admin_user.dart';
import 'audit_entry.dart';
import 'teacher_request_row.dart';

/// Cliente de /api/admin/ — todas las rutas exigen rol admin (403 si no).
class AdminRepository {
  AdminRepository(this._dio);

  final Dio _dio;

  Future<List<AdminUser>> listUsers({String? query, int limit = 50}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/admin/users/',
      queryParameters: {
        'limit': limit,
        if (query != null && query.isNotEmpty) 'query': query,
      },
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(AdminUser.fromJson)
        .toList();
  }

  Future<void> ban(int userId) =>
      _dio.post('/api/admin/users/$userId/ban/');

  Future<void> unban(int userId) =>
      _dio.post('/api/admin/users/$userId/unban/');

  Future<void> deleteUser(int userId) =>
      _dio.delete('/api/admin/users/$userId/');

  Future<void> promote(int userId) =>
      _dio.post('/api/admin/users/$userId/promote/');

  Future<void> demote(int userId) =>
      _dio.post('/api/admin/users/$userId/demote/');

  Future<void> cancelGame(int gameId) =>
      _dio.post('/api/admin/games/$gameId/cancel/');

  Future<void> kickPlayer(int gameId, int playerId) => _dio.post(
        '/api/admin/games/$gameId/kick/',
        data: {'player_id': playerId},
      );

  Future<List<TeacherRequestRow>> teacherRequests() async {
    final res = await _dio.get<List<dynamic>>('/api/admin/teacher-requests/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(TeacherRequestRow.fromJson)
        .toList();
  }

  Future<void> approveTeacherRequest(int requestId) =>
      _dio.post('/api/admin/teacher-requests/$requestId/approve/');

  Future<void> rejectTeacherRequest(int requestId) =>
      _dio.post('/api/admin/teacher-requests/$requestId/reject/');

  /// Alta de club con dueño asignado (solo admin).
  Future<void> createClub({
    required int ownerUserId,
    required String name,
    required String address,
    required String city,
    String? description,
  }) =>
      _dio.post('/api/clubs/', data: {
        'owner_user_id': ownerUserId,
        'name': name,
        'address': address,
        'city': city,
        if (description != null && description.isNotEmpty)
          'description': description,
      });

  Future<List<AuditEntry>> audit({int limit = 100}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/admin/audit/',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(AuditEntry.fromJson)
        .toList();
  }

  Future<List<String>> logs({int lines = 200}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/admin/logs/',
      queryParameters: {'lines': lines},
    );
    return ((res.data?['lines'] as List<dynamic>?) ?? const [])
        .cast<String>();
  }
}
