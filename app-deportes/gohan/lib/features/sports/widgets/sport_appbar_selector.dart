import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/sport_icons.dart';
import '../data/sport_model.dart';
import '../providers/sports_providers.dart';

/// AppBar action that shows the selected sport as its icon and opens a
/// bottom sheet with one icon-tile per sport. Replaces the dropdown in the
/// create-game form — el deporte se elige arriba a la derecha.
class SportAppBarSelector extends ConsumerWidget {
  const SportAppBarSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<Sport> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    Sport? selected;
    for (final s in sports) {
      if (s.id == value) selected = s;
    }
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: scheme.primaryContainer,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openSheet(context, sports),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              sportIcon(selected?.name),
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, List<Sport> sports) async {
    final picked = await showModalBottomSheet<Sport>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deporte', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in sports)
                    _SportTile(
                      sport: s,
                      selected: s.id == value,
                      onTap: () => Navigator.of(ctx).pop(s),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({
    required this.sport,
    required this.selected,
    required this.onTap,
  });

  final Sport sport;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primary : scheme.surfaceContainerHigh;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(sportIcon(sport.name), color: fg, size: 28),
            const SizedBox(height: 6),
            Text(
              sport.name,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
