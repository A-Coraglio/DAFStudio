import 'package:flutter/material.dart';

/// Horizontal divider with an "o" in the middle, used between the
/// email/password submit button and the Google sign-in button on login and
/// register.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('o'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
