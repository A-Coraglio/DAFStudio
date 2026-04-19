import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/court.dart';
import '../data/courts_repository.dart';

final courtsRepositoryProvider = Provider<CourtsRepository>((ref) {
  return CourtsRepository(ref.read(apiClientProvider));
});

/// Courts available for a specific sport (or all if sportId is null). The
/// create-game form uses this to populate the court picker.
final courtsForSportProvider =
    FutureProvider.family<List<Court>, int?>((ref, sportId) async {
  return ref.read(courtsRepositoryProvider).list(sportId: sportId);
});
