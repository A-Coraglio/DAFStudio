import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../../profile/providers/profile_providers.dart';
import '../../sports/providers/sports_providers.dart';
import '../widgets/home_cta_list.dart';
import '../widgets/home_welcome.dart';
import '../widgets/sport_selector_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Onboarding guard: the moment we learn the profile is incomplete, push
    // the user to /complete-profile. Lives here rather than in the router's
    // redirect because the check is async (FutureProvider).
    ref.listen(myProfileProvider, (_, next) {
      next.whenData((profile) {
        if (!profile.isComplete && mounted) {
          context.go('/complete-profile');
        }
      });
    });

    final sportsAsync = ref.watch(sportsListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [SportSelectorButton()],
      ),
      body: sportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: 'No pudimos cargar los deportes.\n$err',
          onRetry: () => ref.invalidate(sportsListProvider),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            HomeWelcome(),
            SizedBox(height: 20),
            HomeCtaList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'profileFab',
        tooltip: 'Perfil',
        onPressed: () => context.push('/profile'),
        child: const Icon(Icons.person),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
