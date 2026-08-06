import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/class_model.dart';
import 'classes_providers.dart';

/// One class offering (teacher) by id — backs the detail screen.
final classDetailProvider = FutureProvider.family<ClassOffering, int>((
  ref,
  teacherId,
) async {
  return ref.read(classesRepositoryProvider).getById(teacherId);
});
