import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/storage/sport_prefs.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/sport_model.dart';
import '../data/sports_repository.dart';

final sportsRepositoryProvider = Provider<SportsRepository>((ref) {
  return SportsRepository(ref.read(apiClientProvider));
});

/// List of all sports from the backend. Cached for the whole session.
final sportsListProvider = FutureProvider<List<Sport>>((ref) async {
  return ref.read(sportsRepositoryProvider).list();
});

/// The user's currently-active sport for browsing/matchmaking.
///
/// Effective value = the last sport the user picked from the home selector
/// (persisted locally, per user) *or*, if they never picked one, their profile
/// favorite chosen during onboarding. So the app opens on the favorite by
/// default and remembers any later choice for the next session.
///
/// It watches [myProfileProvider] so the value re-derives for the right user
/// on login/logout and reflects a changed favorite. Null means "not resolved
/// yet" (profile still loading).
class ActiveSportIdNotifier extends Notifier<int?> {
  int? _userId;
  // Guards the async prefs read against a concurrent set()/rebuild so a stale
  // load can't clobber a fresher choice.
  Object? _loadToken;

  @override
  int? build() {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    _userId = profile?.userId;
    if (profile == null) return null;
    // Show the favorite immediately, then upgrade to the persisted per-user
    // choice once it's read from disk (if there is one).
    _applySavedOverride(profile.userId);
    return profile.favoriteSportId;
  }

  Future<void> _applySavedOverride(int userId) async {
    final token = Object();
    _loadToken = token;
    final saved = await SportPrefs.readActiveSport(userId);
    if (!identical(_loadToken, token)) return; // superseded — bail
    if (saved != null) state = saved;
  }

  Future<void> set(int id) async {
    _loadToken = null; // cancel any in-flight override load
    state = id;
    final userId = _userId;
    if (userId != null) {
      await SportPrefs.writeActiveSport(userId, id);
    }
  }
}

final activeSportIdProvider = NotifierProvider<ActiveSportIdNotifier, int?>(
  ActiveSportIdNotifier.new,
);
