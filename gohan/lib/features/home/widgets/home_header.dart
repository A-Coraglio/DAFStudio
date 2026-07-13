import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/data/player_profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/widgets/profile_avatar.dart';
import '../../sports/widgets/sport_selector_button.dart';
import 'home_stats_line.dart';

/// Personal header replacing the old "Home" AppBar: avatar (→ profile tab),
/// greeting with the user's first name, and the active-sport selector.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _initials(PlayerProfile p) {
    final parts = [p.firstName, p.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => s![0].toUpperCase());
    return parts.isEmpty ? '?' : parts.join();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: ProfileAvatar(
            avatarUrl: profile?.avatarUrl,
            initials: profile == null ? '?' : _initials(profile),
            radius: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile == null
                    ? '${_greeting()} 👋'
                    : '${_greeting()}, ${profile.firstName} 👋',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const HomeStatsLine(),
            ],
          ),
        ),
        const SportSelectorButton(),
      ],
    );
  }
}
