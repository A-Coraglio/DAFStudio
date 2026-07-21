import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../courts/providers/courts_providers.dart';

/// Entrada al panel del club — solo visible si sos dueño de al menos uno.
class MyClubTile extends ConsumerWidget {
  const MyClubTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(myClubsProvider).valueOrNull ?? const [];
    if (clubs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.stadium_outlined),
          title: Text(clubs.length == 1 ? clubs.first.name : 'Mis clubes'),
          subtitle: const Text('Canchas y turnos de tu club'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => clubs.length == 1
              ? context.push('/manage-club/${clubs.first.id}')
              : context.push('/my-club'),
        ),
      ),
    );
  }
}
