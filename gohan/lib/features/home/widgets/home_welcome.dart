import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';

class HomeWelcome extends ConsumerWidget {
  const HomeWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final greeting = profile.maybeWhen(
      data: (p) => 'Hola, ${p.displayName}',
      orElse: () => 'Bienvenido',
    );
    return Text(
      greeting,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
