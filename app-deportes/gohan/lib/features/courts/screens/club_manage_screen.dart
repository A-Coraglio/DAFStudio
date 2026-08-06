import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/courts_providers.dart';
import '../widgets/create_court_sheet.dart';

/// Panel de un club propio: sus canchas (tap → turnos) y alta de canchas.
class ClubManageScreen extends ConsumerWidget {
  const ClubManageScreen({super.key, required this.clubId});

  final int clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clubCourtsProvider(clubId));
    return Scaffold(
      appBar: AppBar(title: const Text('Canchas del club')),
      body: async.when(
        loading: () => const TileListSkeleton(rows: 4),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(clubCourtsProvider(clubId)),
        ),
        data: (courts) => RefreshIndicator(
          onRefresh: () => safeRefresh(() async {
            ref.invalidate(clubCourtsProvider(clubId));
            await ref.read(clubCourtsProvider(clubId).future);
          }),
          child: courts.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Todavía no hay canchas. Creá la primera con el '
                        'botón de abajo.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final court in courts)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            court.isIndoor
                                ? Icons.home_work_outlined
                                : Icons.grass_outlined,
                          ),
                          title: Text(court.name),
                          subtitle: Text(
                            '\$${court.pricePerHour.round()}/h — tocá para '
                            'gestionar sus turnos',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.push('/manage-court/${court.id}'),
                        ),
                      ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateCourtSheet.show(context, clubId),
        icon: const Icon(Icons.add),
        label: const Text('Cancha'),
      ),
    );
  }
}
