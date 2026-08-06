import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/safe_refresh.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/courts_providers.dart';
import '../widgets/my_booking_tile.dart';

/// Mis turnos de cancha reservados (próximos), con cancelación.
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myCourtBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis turnos')),
      body: async.when(
        loading: () => const TileListSkeleton(),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(myCourtBookingsProvider),
        ),
        data: (slots) => RefreshIndicator(
          onRefresh: () => safeRefresh(() async {
            ref.invalidate(myCourtBookingsProvider);
            await ref.read(myCourtBookingsProvider.future);
          }),
          child: slots.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 40),
                    IllustratedEmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Sin turnos reservados',
                      body: 'Reservá una cancha y tu turno aparece acá.',
                      action: FilledButton(
                        onPressed: () => context.push('/book-court'),
                        child: const Text('Reservar cancha'),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => MyBookingTile(slot: slots[i]),
                ),
        ),
      ),
    );
  }
}
