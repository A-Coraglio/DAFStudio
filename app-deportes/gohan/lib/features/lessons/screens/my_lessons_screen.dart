import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/lessons_providers.dart';
import '../widgets/lesson_card.dart';

/// The user's booked lessons, upcoming first — reached from the profile.
class MyLessonsScreen extends ConsumerWidget {
  const MyLessonsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(myLessonsProvider);
    await ref.read(myLessonsProvider.future);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myLessonsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis clases')),
      body: async.when(
        loading: () => const TileListSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          message: 'No pudimos cargar tus clases.',
          onRetry: () => ref.invalidate(myLessonsProvider),
        ),
        data: (lessons) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: lessons.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 40),
                    IllustratedEmptyState(
                      icon: Icons.school_outlined,
                      title: 'Sin clases todavía',
                      body:
                          'Reservá una clase con un profe y va a '
                          'aparecer acá.',
                      action: FilledButton(
                        onPressed: () => context.push('/classes'),
                        child: const Text('Buscar profes'),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => LessonCard(lesson: lessons[i]),
                ),
        ),
      ),
    );
  }
}
