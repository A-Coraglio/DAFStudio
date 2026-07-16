import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../data/class_model.dart';
import '../data/classes_repository.dart';

final classesRepositoryProvider = Provider<ClassesRepository>((ref) {
  return ClassesRepository(ref.read(apiClientProvider));
});

/// Recommended classes for the home carousel — ranked server-side by the
/// user's favorite sport and (best-effort) location.
final recommendedClassesProvider = FutureProvider<List<ClassOffering>>((
  ref,
) async {
  final location = await ref.watch(currentLocationProvider.future);
  return ref
      .read(classesRepositoryProvider)
      .recommended(nearLat: location?.lat, nearLon: location?.lon);
});

// --- Search screen filters ---------------------------------------------------

class ClassFilter {
  final String query; // name search (client-side)
  final int? sportId; // backend
  final double? maxPrice; // backend

  const ClassFilter({this.query = '', this.sportId, this.maxPrice});

  ClassFilter copyWith({
    String? query,
    int? sportId,
    double? maxPrice,
    bool clearSport = false,
    bool clearMaxPrice = false,
  }) {
    return ClassFilter(
      query: query ?? this.query,
      sportId: clearSport ? null : (sportId ?? this.sportId),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }
}

final classFilterProvider = StateProvider<ClassFilter>(
  (_) => const ClassFilter(),
);

/// Backend fetch — only re-runs when the server-side filters (sport, price) or
/// location change, not on every keystroke of the name search.
final classesFetchProvider = FutureProvider<List<ClassOffering>>((ref) async {
  final sportId = ref.watch(classFilterProvider.select((f) => f.sportId));
  final maxPrice = ref.watch(classFilterProvider.select((f) => f.maxPrice));
  final location = await ref.watch(currentLocationProvider.future);
  return ref
      .read(classesRepositoryProvider)
      .list(
        sportId: sportId,
        maxPrice: maxPrice,
        nearLat: location?.lat,
        nearLon: location?.lon,
      );
});

/// The list the screen renders: backend result narrowed by the client-side
/// name search.
final classesListProvider = FutureProvider<List<ClassOffering>>((ref) async {
  final all = await ref.watch(classesFetchProvider.future);
  final query = ref
      .watch(classFilterProvider.select((f) => f.query))
      .trim()
      .toLowerCase();
  if (query.isEmpty) return all;
  return all
      .where((c) => c.displayName.toLowerCase().contains(query))
      .toList();
});
