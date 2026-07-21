import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/classes_providers.dart';
import '../widgets/class_card.dart';
import '../widgets/classes_filter_bar.dart';

/// Full classes search/list, reached from the home carousel's "Ver todas".
class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  Future<void> _refresh(WidgetRef ref) => safeRefresh(() async {
    ref.invalidate(classesFetchProvider);
    await ref.read(classesListProvider.future);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(classesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Clases')),
      body: Column(
        children: [
          const ClassesFilterBar(),
          Expanded(
            child: async.when(
              loading: () => const TileListSkeleton(),
              error: (err, _) => ErrorView(
                error: err,
                message: 'No pudimos cargar las clases.',
                onRetry: () => ref.invalidate(classesFetchProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: items.isEmpty
                    ? ListView(
                        // Scrollable so pull-to-refresh still works when the
                        // filtered list is empty.
                        children: const [
                          SizedBox(height: 40),
                          IllustratedEmptyState(
                            icon: Icons.school_outlined,
                            title: 'No hay clases',
                            body:
                                'Probá con otros filtros, o volvé más '
                                'adelante: siempre se suman profes nuevos.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => ClassCard(
                          offering: items[i],
                          // Lead each card with the screen's sport filter.
                          preferredSportId: ref.watch(
                            classFilterProvider.select((f) => f.sportId),
                          ),
                          onTap: () =>
                              context.push('/classes/${items[i].id}'),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
