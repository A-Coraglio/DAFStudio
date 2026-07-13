import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sport_model.dart';
import '../providers/sports_providers.dart';

/// Appbar action: current active sport + bottom-sheet picker.
class SportSelectorButton extends ConsumerWidget {
  const SportSelectorButton({super.key});

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    List<Sport> sports,
    int? currentId,
  ) async {
    final chosen = await showModalBottomSheet<Sport>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: sports
              .map(
                (s) => ListTile(
                  title: Text(s.name),
                  trailing: currentId == s.id ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(ctx, s),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (chosen == null) return;
    await ref.read(activeSportIdProvider.notifier).set(chosen.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsAsync = ref.watch(sportsListProvider);
    final activeSportId = ref.watch(activeSportIdProvider);

    return sportsAsync.maybeWhen(
      data: (sports) {
        final active = activeSportId == null
            ? null
            : sports.cast<Sport?>().firstWhere(
                (s) => s?.id == activeSportId,
                orElse: () => null,
              );
        return TextButton.icon(
          onPressed: () => _pick(context, ref, sports, activeSportId),
          icon: const Icon(Icons.sports),
          label: Text(active?.name ?? 'Elegir deporte'),
        );
      },
      orElse: () => const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
