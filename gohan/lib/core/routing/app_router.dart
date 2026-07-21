import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/chats/screens/chat_list_screen.dart';
import '../../features/chats/screens/chat_screen.dart';
import '../../features/games/screens/create_game_screen.dart';
import '../../features/games/screens/game_detail_screen.dart';
import '../../features/games/screens/games_feed_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/matchmaking/screens/matchmaking_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/complete_profile_screen.dart';
import '../../features/profile/screens/my_games_screen.dart';
import '../../features/profile/screens/players_discovery_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/tournaments/screens/tournament_detail_screen.dart';
import '../../features/tournaments/screens/tournaments_screen.dart';
import '../../features/classes/screens/class_detail_screen.dart';
import '../../features/classes/screens/classes_screen.dart';
import '../../features/lessons/screens/my_lessons_screen.dart';
import '../providers/core_providers.dart';
import 'scaffold_with_nav.dart';

/// Auth-aware router.
///
/// The 5 main sections (home, games, matchmaking, chats, profile) live inside
/// a [StatefulShellRoute] so they share a persistent bottom navigation bar and
/// each keeps its own navigation stack. Detail screens and forms are declared
/// as top-level routes so they push full-screen over the shell.
///
/// Redirect logic is session-based:
///   - loading           → splash (`/`)
///   - unauthenticated   → /login or /register only
///   - authenticated     → everything except /login, /register is ok.
///
/// The onboarding redirect (incomplete profile → /complete-profile) lives in
/// HomeScreen itself because the check is async (FutureProvider) and doesn't
/// fit the synchronous router redirect nicely.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (session.isLoading) {
        return loc == '/' ? null : '/';
      }
      final authRoutes = {'/login', '/register'};
      if (session.isUnauthenticated) {
        if (authRoutes.contains(loc)) return null;
        return '/login';
      }
      // Authenticated.
      if (loc == '/' || authRoutes.contains(loc)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/complete-profile',
        builder: (_, _) => const CompleteProfileScreen(),
      ),
      GoRoute(path: '/games/new', builder: (_, _) => const CreateGameScreen()),
      // :id routes guard against non-numeric ids (hand-edited URLs on web)
      // by bouncing back to the section list instead of crashing the build.
      GoRoute(
        path: '/games/:id',
        redirect: (_, state) =>
            int.tryParse(state.pathParameters['id']!) == null ? '/games' : null,
        builder: (_, state) =>
            GameDetailScreen(gameId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/chats/:id',
        redirect: (_, state) =>
            int.tryParse(state.pathParameters['id']!) == null ? '/chats' : null,
        builder: (_, state) =>
            ChatScreen(chatId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/players',
        builder: (_, _) => const PlayersDiscoveryScreen(),
      ),
      GoRoute(path: '/my-games', builder: (_, _) => const MyGamesScreen()),
      GoRoute(
        path: '/tournaments',
        builder: (_, _) => const TournamentsScreen(),
      ),
      GoRoute(
        path: '/tournaments/:id',
        redirect: (_, state) =>
            int.tryParse(state.pathParameters['id']!) == null
            ? '/tournaments'
            : null,
        builder: (_, state) => TournamentDetailScreen(
          tournamentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/classes', builder: (_, _) => const ClassesScreen()),
      GoRoute(
        path: '/classes/:id',
        redirect: (_, state) =>
            int.tryParse(state.pathParameters['id']!) == null
            ? '/classes'
            : null,
        builder: (_, state) => ClassDetailScreen(
          teacherId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/my-lessons',
        builder: (_, _) => const MyLessonsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/players/:id',
        redirect: (_, state) =>
            int.tryParse(state.pathParameters['id']!) == null
            ? '/players'
            : null,
        builder: (_, state) => PublicProfileScreen(
          playerId: int.parse(state.pathParameters['id']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => ScaffoldWithNav(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/games',
                builder: (_, _) => const GamesFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matchmaking',
                builder: (_, _) => const MatchmakingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (_, _) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
