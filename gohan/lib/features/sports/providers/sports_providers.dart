import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
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
/// their persisted favorite sport — this is session-scoped and changed from
/// the home dropdown. Null means "no sport selected yet".
final activeSportIdProvider = StateProvider<int?>((ref) => null);
