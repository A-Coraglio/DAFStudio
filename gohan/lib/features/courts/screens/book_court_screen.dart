import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../providers/courts_providers.dart';
import '../widgets/book_slot_tile.dart';
import '../widgets/club_court_pickers.dart';

/// Reservar cancha: elegís club y cancha, y reservás un turno libre.
class BookCourtScreen extends ConsumerStatefulWidget {
  const BookCourtScreen({super.key});

  @override
  ConsumerState<BookCourtScreen> createState() => _BookCourtScreenState();
}

class _BookCourtScreenState extends ConsumerState<BookCourtScreen> {
  int? _clubId;
  int? _courtId;

  @override
  Widget build(BuildContext context) {
    final slotsAsync =
        _courtId == null ? null : ref.watch(courtSlotsProvider(_courtId!));
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar cancha')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClubCourtPickers(
            clubId: _clubId,
            courtId: _courtId,
            onClub: (id) => setState(() {
              _clubId = id;
              _courtId = null;
            }),
            onCourt: (id) => setState(() => _courtId = id),
          ),
          if (slotsAsync != null) ...[
            const SizedBox(height: 16),
            Text('Turnos', style: Theme.of(context).textTheme.labelLarge),
            slotsAsync.when(
              loading: () =>
                  const TileListSkeleton(rows: 4, shrinkWrap: true),
              error: (err, _) => ErrorView(
                error: err,
                onRetry: () => ref.invalidate(courtSlotsProvider(_courtId!)),
              ),
              data: (slots) => slots.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Esta cancha no tiene turnos próximos cargados.',
                      ),
                    )
                  : Column(
                      children: [
                        for (final slot in slots) BookSlotTile(slot: slot),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
