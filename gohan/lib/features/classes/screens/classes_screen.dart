import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorView(
                error: err,
                message: 'No pudimos cargar las clases.',
                onRetry: () => ref.invalidate(classesFetchProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: items.isEmpty
                    ? const _Empty()
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
                          // No dedicated teacher detail screen yet.
                          onTap: () {},
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Icon(Icons.school_outlined, size: 48),
              SizedBox(height: 12),
              Text('No hay clases con esos filtros'),
            ],
          ),
        ),
      ],
    );
  }
}
