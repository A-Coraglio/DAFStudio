import 'package:flutter/material.dart';

/// Brand header shown above the auth forms — gives the first screens an
/// identity instead of a bare form. Includes its own bottom spacing.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.sports_handball,
            size: 40,
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'DAFStudio',
          style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
