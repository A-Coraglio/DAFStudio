import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Vertical brand-tinted gradient behind the auth forms — the first screens
/// stop being a bare form on a flat background. Fades into the surface so
/// the fields keep their normal contrast.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .45],
          colors: [brandTint(Theme.of(context).brightness), scheme.surface],
        ),
      ),
      child: child,
    );
  }
}
