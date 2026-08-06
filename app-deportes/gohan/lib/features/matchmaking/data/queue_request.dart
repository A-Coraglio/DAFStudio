/// Body for `POST /api/matchmaking/queue/`. Matches `QueueInputDTO` in the
/// backend.
class QueueRequest {
  final int sportId;
  final double maxRadiusKm;
  final double originLat;
  final double originLon;
  final DateTime windowStart;
  final DateTime windowEnd;
  final String mode; // casual | competitive

  const QueueRequest({
    required this.sportId,
    required this.maxRadiusKm,
    required this.originLat,
    required this.originLon,
    required this.windowStart,
    required this.windowEnd,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
    'sport_id': sportId,
    'max_radius_km': maxRadiusKm,
    'origin_lat': originLat,
    'origin_lon': originLon,
    'window_start': windowStart.toIso8601String(),
    'window_end': windowEnd.toIso8601String(),
    'mode': mode,
  };
}
