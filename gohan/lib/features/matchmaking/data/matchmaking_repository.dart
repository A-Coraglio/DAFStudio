import 'package:dio/dio.dart';

import 'matchmaking_status.dart';
import 'matchmaking_ticket.dart';
import 'queue_request.dart';

class MatchmakingRepository {
  MatchmakingRepository(this._dio);

  final Dio _dio;

  Future<MatchmakingTicket> queue(QueueRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/matchmaking/queue/',
      data: req.toJson(),
    );
    return MatchmakingTicket.fromJson(res.data!);
  }

  Future<void> cancel() async {
    await _dio.delete('/api/matchmaking/queue/');
  }

  Future<MatchmakingStatus> status() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/matchmaking/status/',
    );
    return MatchmakingStatus.fromJson(res.data!);
  }

  Future<MatchmakingStatus> accept(int ticketId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/matchmaking/tickets/$ticketId/accept/',
    );
    return MatchmakingStatus.fromJson(res.data!);
  }

  Future<MatchmakingTicket> reject(int ticketId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/matchmaking/tickets/$ticketId/reject/',
    );
    return MatchmakingTicket.fromJson(res.data!);
  }
}
