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
/// First fetch failing surfaces the error (retry screen); after that,
/// transient blips are swallowed so a user waiting in queue never sees the
/// panel replaced by an error mid-wait.
final matchmakingStatusStreamProvider =
    StreamProvider.autoDispose<MatchmakingStatus>((ref) async* {
      final repo = ref.read(matchmakingRepositoryProvider);
      var hasData = false;
      while (true) {
        try {
          yield await repo.status();
          hasData = true;
        } catch (_) {
          if (!hasData) rethrow;
        }
        await Future.delayed(const Duration(seconds: 3));
      }
    });
