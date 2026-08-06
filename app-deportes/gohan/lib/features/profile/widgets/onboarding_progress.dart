import 'package:flutter/material.dart';

/// "Paso X de N" label + progress bar for the onboarding flow.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.step,
    required this.total,
  });

  /// Zero-based index of the current step.
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso ${step + 1} de $total',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (step + 1) / total,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
