import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../games/providers/games_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../sports/providers/sports_providers.dart';
import '../../classes/providers/classes_providers.dart';
import '../../classes/widgets/classes_carousel.dart';
import '../../tournaments/providers/tournaments_providers.dart';
import '../../tournaments/widgets/tournaments_carousel.dart';
import '../providers/home_providers.dart';
import '../widgets/home_header.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/matchmaking_banner.dart';
import '../widgets/nearby_games_carousel.dart';
import '../widgets/next_game_card.dart';
import '../widgets/quick_actions_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Onboarding guard: the moment we learn the profile is incomplete, push
    // the user to /complete-profile. Lives here rather than in the router's
    // redirect because the check is async (FutureProvider).
    ref.listen(myProfileProvider, (_, next) {
      next.whenData((profile) {
        if (!profile.isComplete && context.mounted) {
          context.go('/complete-profile');
        }
      });
    });

    final sportsAsync = ref.watch(sportsListProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      // Degradado sutil de marca arriba que funde al surface — saca a la
      // home del "fondo plano de template" sin ensuciar el contenido.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, .35],
            colors: [brandTint(Theme.of(context).brightness), scheme.surface],
          ),
        ),
        child: SafeArea(
          child: sportsAsync.when(
            loading: () => const HomeSkeleton(),
            error: (err, _) => ErrorView(
              error: err,
              message: 'No pudimos cargar los deportes.',
              onRetry: () => ref.invalidate(sportsListProvider),
            ),
            data: (_) => RefreshIndicator(
              onRefresh: () => safeRefresh(() async {
                ref.invalidate(myGamesProvider);
                ref.invalidate(nextGameProvider);
                ref.invalidate(feedGamesProvider);
                ref.invalidate(recommendedTournamentsProvider);
                ref.invalidate(recommendedClassesProvider);
                await ref.read(nextGameProvider.future);
              }),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  HomeHeader(),
                  SizedBox(height: 20),
                  MatchmakingBanner(),
                  NextGameCard(),
                  SizedBox(height: 20),
                  QuickActionsRow(),
                  SizedBox(height: 20),
                  NearbyGamesCarousel(),
                  SizedBox(height: 20),
                  TournamentsCarousel(),
                  SizedBox(height: 20),
                  ClassesCarousel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
