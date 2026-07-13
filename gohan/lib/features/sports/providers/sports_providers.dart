import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/storage/sport_prefs.dart';
import '../data/sport_model.dart';
import '../data/sports_repository.dart';

final sportsRepositoryProvider = Provider<SportsRepository>((ref) {
  return SportsRepository(ref.read(apiClientProvider));
});

/// List of all sports from the backend. Cached for the whole session.
final sportsListProvider = FutureProvider<List<Sport>>((ref) async {
  return ref.read(sportsRepositoryProvider).list();
});

/// The user's currently-active sport for browsing/matchmaking. Distinct from
/// their favorite sport — this one is changed from the home dropdown and
/// persisted locally so it survives restarts. Null means "no sport yet".
class ActiveSportIdNotifier extends Notifier<int?> {
  @override
  int? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final value = await SportPrefs.readActiveSport();
    if (value != null) state = value;
  }

  Future<void> set(int id) async {
    state = id;
    await SportPrefs.writeActiveSport(id);
  }
}

final activeSportIdProvider = NotifierProvider<ActiveSportIdNotifier, int?>(
  ActiveSportIdNotifier.new,
);
