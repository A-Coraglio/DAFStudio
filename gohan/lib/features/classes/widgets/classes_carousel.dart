import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/see_more_card.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../providers/classes_providers.dart';
import 'class_card.dart';

/// Home carousel of recommended classes. The trailing "Ver más" card opens
/// the full classes search screen.
class ClassesCarousel extends ConsumerWidget {
  const ClassesCarousel({super.key});

  static const _maxItems = 10;
  static const _cardWidth = 300.0;
  static const _stripHeight = 128.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendedClassesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Clases cerca tuyo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        async.when(
          loading: () => const SkeletonBox(height: _stripHeight, radius: 16),
          error: (_, _) => const _ErrorStrip(),
          data: (items) {
            if (items.isEmpty) return const _EmptyStrip();
            final count =
                items.length > _maxItems ? _maxItems : items.length;
            return SizedBox(
              height: _stripHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: count + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  if (i == count) {
                    return SeeMoreCard(onTap: () => context.push('/classes'));
                  }
                  return SizedBox(
                    width: _cardWidth,
                    child: ClassCard(
                      offering: items[i],
                      onTap: () => context.push('/classes'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.school_outlined),
        title: const Text('Todavía no hay clases cerca'),
        subtitle: const Text('Tocá para ver todas las opciones'),
        onTap: () => context.push('/classes'),
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
