import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'court_slot.dart';

/// Turnos de cancha: gestión del club (crear/quitar/bloquear/liberar) y
/// reserva de jugadores. El backend decide qué acciones permite cada rol.
class CourtSlotsRepository {
  CourtSlotsRepository(this._dio);

  final Dio _dio;

  Future<List<CourtSlot>> list(int courtId) async {
    final res = await _dio.get<List<dynamic>>('/api/courts/$courtId/slots/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(CourtSlot.fromJson)
        .toList();
  }

  Future<CourtSlot> create(
    int courtId, {
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/courts/$courtId/slots/',
      data: {
        'start_time': start.toIso8601String(),
        'end_time': end.toIso8601String(),
      },
    );
    return CourtSlot.fromJson(requireData(res));
  }

  Future<void> delete(int slotId) =>
      _dio.delete('/api/courts/slots/$slotId/');

  Future<void> block(int slotId) =>
      _dio.post('/api/courts/slots/$slotId/block/');

  Future<void> free(int slotId) =>
      _dio.post('/api/courts/slots/$slotId/free/');

  Future<void> book(int slotId) =>
      _dio.post('/api/courts/slots/$slotId/book/');

  Future<void> cancelBooking(int slotId) =>
      _dio.post('/api/courts/slots/$slotId/cancel-booking/');

  /// Mis turnos reservados (próximos), con cancha y club.
  Future<List<CourtSlot>> myBookings() async {
    final res = await _dio.get<List<dynamic>>('/api/courts/my-bookings/');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(CourtSlot.fromJson)
        .toList();
  }
}
