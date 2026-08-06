import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/busy_slot.dart';
import '../data/lesson_model.dart';
import '../data/lessons_repository.dart';

final lessonsRepositoryProvider = Provider<LessonsRepository>((ref) {
  return LessonsRepository(ref.read(apiClientProvider));
});

/// The caller's lessons (upcoming first, then past). Backs "Mis clases" and
/// the per-teacher section of the class detail. Invalidated after every
/// booking / cancellation and on logout (session cache reset).
final myLessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  return ref.read(lessonsRepositoryProvider).mine();
});

/// Upcoming occupied slots of a teacher — the class detail shows them so a
/// clash is visible BEFORE booking (not only via the 409). Invalidated after
/// every booking/cancellation. AutoDispose: solo vive mientras el detalle
/// está abierto.
final teacherBusySlotsProvider = FutureProvider.autoDispose
    .family<List<BusySlot>, int>((ref, teacherId) async {
      return ref.read(lessonsRepositoryProvider).busy(teacherId);
    });
