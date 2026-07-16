import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/labels.dart';
import '../../../core/theme/app_colors.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_thumbnail.dart';
import '../data/class_model.dart';

/// Card for a class offering (a teacher) — used in the home carousel and the
/// classes search list.
class ClassCard extends ConsumerWidget {
  const ClassCard({super.key, required this.offering, required this.onTap});

  final ClassOffering offering;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    final firstSportId = offering.sportIds.isNotEmpty
        ? offering.sportIds.first
        : null;
    String? sportName;
    final sportNames = <String>[];
    for (final id in offering.sportIds) {
      for (final s in sports) {
        if (s.id == id) {
          sportNames.add(s.name);
          if (id == firstSportId) sportName = s.name;
        }
      }
    }
    final scheme = Theme.of(context).colorScheme;
    final distance = distanceLabel(offering.distanceKm);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportThumbnail(
                sportName: sportName,
                size: 52,
                borderRadius: AppRadius.input,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offering.displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sportNames.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sportNames.join(' · '),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (offering.bio != null && offering.bio!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        offering.bio!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Chip(
                          icon: Icons.payments_outlined,
                          label: '\$${offering.pricePerHour.round()}/h',
                        ),
                        if (offering.experienceYears != null)
                          _Chip(
                            icon: Icons.workspace_premium_outlined,
                            label: '${offering.experienceYears} años',
                          ),
                        if (distance != null)
                          _Chip(icon: Icons.place_outlined, label: distance),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
