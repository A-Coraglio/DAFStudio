import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/matchmaking_repository.dart';
import '../data/matchmaking_status.dart';

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  return MatchmakingRepository(ref.read(apiClientProvider));
});

/// Default origin when we don't have geolocation yet (MVP). Roughly the
/// center of Buenos Aires. Replace with geolocator in a follow-up.
const defaultOriginLat = -34.6037;
const defaultOriginLon = -58.3816;

/// Polls `GET /api/matchmaking/status/` every 3 seconds while something is
/// listening. `autoDispose` cancels the loop the moment the matchmaking
/// screen leaves the tree.
final matchmakingStatusStreamProvider =
    StreamProvider.autoDispose<MatchmakingStatus>((ref) async* {
      final repo = ref.read(matchmakingRepositoryProvider);
      while (true) {
        yield await repo.status();
        await Future.delayed(const Duration(seconds: 3));
      }
    });
