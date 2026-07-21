import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_thumbnail.dart';
import '../data/class_model.dart';

/// Header row of the class detail: sport thumbnail, teacher name and the
/// sports they teach.
class ClassHeader extends ConsumerWidget {
  const ClassHeader({super.key, required this.offering});

  final ClassOffering offering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    final sportNames = <String>[
      for (final id in offering.sportIds)
        for (final s in sports)
          if (s.id == id) s.name,
    ];
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SportThumbnail(
          sportName: sportNames.isEmpty ? null : sportNames.first,
          size: 56,
          borderRadius: AppRadius.input,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offering.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (sportNames.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sportNames.join(' · '),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
