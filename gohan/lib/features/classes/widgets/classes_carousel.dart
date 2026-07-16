import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/skeleton_box.dart';
import '../providers/classes_providers.dart';
import 'class_card.dart';

/// Home carousel of recommended classes + a "Ver todas" action that opens the
/// full classes search screen.
class ClassesCarousel extends ConsumerWidget {
  const ClassesCarousel({super.key});

  static const _maxItems = 8;
  static const _cardWidth = 300.0;
  static const _stripHeight = 128.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendedClassesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Clases cerca tuyo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/classes'),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        async.when(
          loading: () => const SkeletonBox(height: _stripHeight, radius: 16),
          error: (_, _) => const _ErrorStrip(),
          data: (items) => items.isEmpty
              ? const _EmptyStrip()
              : SizedBox(
                  height: _stripHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        items.length > _maxItems ? _maxItems : items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                      width: _cardWidth,
                      child: ClassCard(
                        offering: items[i],
                        onTap: () => context.push('/classes'),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.school_outlined),
        title: Text('Todavía no hay clases cerca'),
        subtitle: Text('Mirá todas las opciones en "Ver todas"'),
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.error_outline),
        title: Text('No pudimos cargar las clases'),
      ),
    );
  }
}
