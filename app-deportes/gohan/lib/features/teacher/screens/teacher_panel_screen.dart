import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_lessons_card.dart';
import '../widgets/teacher_profile_card.dart';

/// Panel del profesor: su perfil (editable) y su agenda de clases con
/// confirmación/rechazo de reservas.
class TeacherPanelScreen extends ConsumerWidget {
  const TeacherPanelScreen({super.key});

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(myTeacherStatusProvider);
    ref.invalidate(teachingLessonsProvider);
    await ref.read(myTeacherStatusProvider.future);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myTeacherStatusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de profesor')),
      body: async.when(
        loading: () => const TileListSkeleton(rows: 4),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myTeacherStatusProvider),
        ),
        data: (status) => status.teacher == null
            ? const Center(child: Text('No sos profesor todavía.'))
            : RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TeacherProfileCard(teacher: status.teacher!),
                    const SizedBox(height: 12),
                    const TeacherLessonsCard(),
                  ],
                ),
              ),
      ),
    );
  }
}
