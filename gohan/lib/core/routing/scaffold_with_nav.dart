import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chats/providers/chats_providers.dart';

/// Bottom-nav shell hosting the 5 main tabs. Each tab is a branch of the
/// [StatefulShellRoute] so its navigation stack survives tab switches. The
/// Chats tab carries a live unread badge.
class ScaffoldWithNav extends ConsumerWidget {
  const ScaffoldWithNav({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _onTap(int index) {
    // Re-tapping the active tab pops it back to the branch root.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  Widget _chatsIcon(IconData icon, int unread) {
    return Badge(
      isLabelVisible: unread > 0,
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadTotalProvider).valueOrNull ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.sports_outlined),
            selectedIcon: Icon(Icons.sports),
            label: 'Partidos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Jugar ya',
          ),
          NavigationDestination(
            icon: _chatsIcon(Icons.chat_bubble_outline, unread),
            selectedIcon: _chatsIcon(Icons.chat_bubble, unread),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
