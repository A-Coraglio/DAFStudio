import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/format/dates.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/court_slot.dart';
import '../providers/courts_providers.dart';

/// Turno visto por un jugador: libre → Reservar; mío → Cancelar; el resto
/// se muestra ocupado.
class BookSlotTile extends ConsumerStatefulWidget {
  const BookSlotTile({super.key, required this.slot});

  final CourtSlot slot;

  @override
  ConsumerState<BookSlotTile> createState() => _BookSlotTileState();
}

class _BookSlotTileState extends ConsumerState<BookSlotTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() op, String msg) async {
    setState(() => _busy = true);
    try {
      await op();
      ref.invalidate(courtSlotsProvider(widget.slot.courtId));
      ref.invalidate(myCourtBookingsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final repo = ref.read(courtSlotsRepositoryProvider);
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;
    final mine = slot.bookedByPlayerId != null &&
        slot.bookedByPlayerId == myPlayerId;
    return ListTile(
      dense: true,
      title: Text('${formatSchedule(slot.start)} – ${formatHour(slot.end)}'),
      subtitle: mine
          ? const Text('Reservado por vos')
          : slot.isFree
          ? const Text('Libre')
          : const Text('Ocupado'),
      trailing: _busy
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : mine
          ? TextButton(
              onPressed: () => _run(
                () => repo.cancelBooking(slot.id),
                'Reserva cancelada',
              ),
              child: const Text('Cancelar'),
            )
          : slot.isFree
          ? FilledButton.tonal(
              onPressed: () =>
                  _run(() => repo.book(slot.id), '¡Turno reservado!'),
              child: const Text('Reservar'),
            )
          : null,
    );
  }
}
