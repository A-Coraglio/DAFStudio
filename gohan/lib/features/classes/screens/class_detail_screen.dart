import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../../lessons/providers/lessons_providers.dart';
import '../data/class_model.dart';
import '../providers/class_detail_providers.dart';
import '../widgets/book_lesson_sheet.dart';
import '../widgets/class_info_card.dart';
import '../widgets/class_lessons_card.dart';

/// Detail of a class offering (teacher): info, your booked lessons with them
/// and the "reservar" bar.
class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({super.key, required this.teacherId});

  final int teacherId;

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(classDetailProvider(teacherId));
    ref.invalidate(myLessonsProvider);
    await ref.read(classDetailProvider(teacherId).future);
  });

  void _openBookSheet(BuildContext context, ClassOffering offering) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BookLessonSheet(offering: offering),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(classDetailProvider(teacherId));
    return Scaffold(
      appBar: AppBar(title: const Text('Clase')),
      body: async.when(
        loading: () => const TileListSkeleton(rows: 4),
        error: (err, _) => ErrorView(
          error: err,
          message: 'No pudimos cargar la clase.',
          onRetry: () => ref.invalidate(classDetailProvider(teacherId)),
        ),
        data: (offering) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClassInfoCard(offering: offering),
              const SizedBox(height: 12),
              ClassLessonsCard(teacherId: teacherId),
            ],
          ),
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (offering) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _openBookSheet(context, offering),
                child: const Text('Reservar clase'),
              ),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}
