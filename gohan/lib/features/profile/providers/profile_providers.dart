import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/player_profile.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiClientProvider));
});

/// The current user's player profile. Backs the profile screen and any widget
/// that shows ranking_points / level.
final myProfileProvider = FutureProvider<PlayerProfile>((ref) async {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

/// Public profile of an arbitrary player by id. Backs the `/players/:id`
/// screen reached by tapping a player in a game's roster.
final playerProfileProvider =
    FutureProvider.family<PlayerProfile, int>((ref, playerId) async {
  return ref.read(profileRepositoryProvider).getPlayer(playerId);
});
