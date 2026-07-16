import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
