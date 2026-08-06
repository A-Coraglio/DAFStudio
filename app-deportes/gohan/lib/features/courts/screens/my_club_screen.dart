import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/courts_providers.dart';

/// Clubes que administrás. Con uno solo va directo al panel de ese club.
class MyClubScreen extends ConsumerWidget {
  const MyClubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myClubsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi club')),
      body: async.when(
        loading: () => const TileListSkeleton(rows: 2),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myClubsProvider),
        ),
        data: (clubs) => clubs.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No administrás ningún club. Los clubes los da de alta '
                    'un administrador de DAFStudio.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final club in clubs)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.stadium_outlined),
                        title: Text(club.name),
                        subtitle: Text('${club.address} · ${club.city}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/manage-club/${club.id}'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
