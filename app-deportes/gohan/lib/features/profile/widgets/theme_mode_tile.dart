import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_mode_provider.dart';

/// Segmented control for picking the app's theme mode. Persists automatically
/// via `themeModeProvider`.
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.brightness_6_outlined),
                const SizedBox(width: 12),
                Text('Tema', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest),
                  label: Text('Sistema'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Claro'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Oscuro'),
                ),
              ],
              selected: {current},
              onSelectionChanged: (selection) {
                ref.read(themeModeProvider.notifier).set(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
