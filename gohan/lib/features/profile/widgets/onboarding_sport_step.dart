import 'package:flutter/material.dart';

import '../../../core/widgets/primary_submit_button.dart';
import '../../sports/widgets/sport_dropdown_field.dart';

/// Step 2 of onboarding — favorite sport. The final step, so its button
/// submits the whole profile.
class OnboardingSportStep extends StatelessWidget {
  const OnboardingSportStep({
    super.key,
    required this.sportId,
    required this.onChanged,
    required this.onSubmit,
    required this.loading,
  });

  final int? sportId;
  final ValueChanged<int?> onChanged;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuál es tu deporte?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Lo usamos para el feed y el matchmaking. Podés cambiarlo cuando '
          'quieras desde la home.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        SportDropdownField(value: sportId, onChanged: onChanged),
        const SizedBox(height: 24),
        PrimarySubmitButton(
          label: 'Empezar a jugar',
          onPressed: onSubmit,
          loading: loading,
        ),
      ],
    );
  }
}
