import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/providers/session_cache_reset.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scroll_behavior.dart';

void main() {
  runApp(const ProviderScope(child: GohanApp()));
}

class GohanApp extends ConsumerWidget {
  const GohanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Any path out of a session (logout button, 401 interceptor) must drop
    // the previous user's cached data before someone else logs in.
    ref.listen(sessionProvider, (previous, next) {
      if (previous?.isAuthenticated == true && next.isUnauthenticated) {
        resetUserScopedCaches(ref);
      }
    });
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DAFStudio',
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
