import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Brand header shown above the auth forms — gives the first screens an
/// identity instead of a bare form. Includes its own bottom spacing.
/// Wordmark treatment: brand-gradient tile with an accent bolt, and the
/// name in the display face with an accent full stop.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final accent = Theme.of(context).extension<AppColors>()!.accent;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: brandGradient(Theme.of(context).brightness),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Icon(Icons.bolt, size: 40, color: accent),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: 'DAFStudio',
            style: text.headlineMedium,
            children: [
              TextSpan(
                text: '.',
                style: text.headlineMedium?.copyWith(color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
