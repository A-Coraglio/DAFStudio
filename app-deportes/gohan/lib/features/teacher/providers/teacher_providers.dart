import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../lessons/data/lesson_model.dart';
import '../../lessons/providers/lessons_providers.dart';
import '../data/teacher_repository.dart';
import '../data/teacher_status.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(ref.read(apiClientProvider));
});

/// Estado del modo profesor del usuario logueado — gatea el tile del perfil
/// y el panel. User-scoped: está en el session cache reset.
final myTeacherStatusProvider = FutureProvider<TeacherStatus>((ref) async {
  return ref.read(teacherRepositoryProvider).myStatus();
});

/// Agenda del profe: sus clases (pendientes primero, con alumno).
final teachingLessonsProvider = FutureProvider.autoDispose<List<Lesson>>((
  ref,
) async {
  return ref.read(lessonsRepositoryProvider).teaching();
});
