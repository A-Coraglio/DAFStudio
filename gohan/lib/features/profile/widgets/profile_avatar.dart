import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

/// Circular avatar that shows the player's uploaded image if present,
/// or falls back to their initials. `avatarUrl` comes from the backend as
/// a relative path (e.g. `/uploads/avatars/p1_ab.png`) — we prefix
/// `apiBaseUrl` to turn it into a fetchable URL.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.initials,
    this.radius = 28,
  });

  final String? avatarUrl;
  final String initials;
  final double radius;

  String? _absoluteUrl() {
    final u = avatarUrl;
    if (u == null || u.isEmpty) return null;
    if (u.startsWith('http')) return u;
    return '${AppConfig.apiBaseUrl}$u';
  }

  @override
  Widget build(BuildContext context) {
    final url = _absoluteUrl();
    if (url != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(
        initials,
        style: TextStyle(fontSize: radius * 0.7),
      ),
    );
  }
}
