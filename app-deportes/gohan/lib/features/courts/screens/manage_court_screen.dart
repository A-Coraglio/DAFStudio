import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/courts_providers.dart';
import '../widgets/create_slot_sheet.dart';
import '../widgets/manage_slot_tile.dart';

/// Turnos de una cancha, vista del administrador: crear, bloquear, liberar
/// y quitar turnos, viendo quién reservó cada uno.
class ManageCourtScreen extends ConsumerWidget {
  const ManageCourtScreen({super.key, required this.courtId});

  final int courtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(courtSlotsProvider(courtId));
    return Scaffold(
      appBar: AppBar(title: const Text('Turnos de la cancha')),
      body: async.when(
        loading: () => const TileListSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(courtSlotsProvider(courtId)),
        ),
        data: (slots) => RefreshIndicator(
          onRefresh: () => safeRefresh(() async {
            ref.invalidate(courtSlotsProvider(courtId));
            await ref.read(courtSlotsProvider(courtId).future);
          }),
          child: slots.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 40),
                    IllustratedEmptyState(
                      icon: Icons.schedule_outlined,
                      title: 'Sin turnos',
                      body: 'Creá los turnos de esta cancha y los jugadores '
                          'van a poder reservarlos.',
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: slots.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => ManageSlotTile(slot: slots[i]),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateSlotSheet.show(context, courtId),
        icon: const Icon(Icons.add),
        label: const Text('Turno'),
      ),
    );
  }
}
