import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../../../core/widgets/primary_submit_button.dart';

const _levels = ['beginner', 'intermediate', 'advanced'];

/// Step 3 of onboarding — self-reported level. Optional: matchmaking and
/// filters work without it, so there's an explicit skip.
class OnboardingLevelStep extends StatelessWidget {
  const OnboardingLevelStep({
    super.key,
    required this.level,
    required this.onChanged,
    required this.onContinue,
  });

  final String? level;
  final ValueChanged<String?> onChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuál es tu nivel?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Ayuda a emparejarte con gente pareja. Podés cambiarlo cuando '
          'quieras desde tu perfil.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            for (final l in _levels)
              ChoiceChip(
                label: Text(levelLabel(l)),
                selected: level == l,
                onSelected: (sel) => onChanged(sel ? l : null),
              ),
          ],
        ),
        const SizedBox(height: 24),
        PrimarySubmitButton(
          label: 'Siguiente',
          onPressed: onContinue,
          loading: false,
        ),
        Center(
          child: TextButton(
            onPressed: () {
              onChanged(null);
              onContinue();
            },
            child: const Text('Omitir por ahora'),
          ),
        ),
      ],
    );
  }
}
