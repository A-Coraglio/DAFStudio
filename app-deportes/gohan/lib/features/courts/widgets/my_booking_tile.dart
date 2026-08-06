import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/format/dates.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/court_slot.dart';
import '../providers/courts_providers.dart';

/// Un turno reservado en "Mis turnos": cancha + club + horario + cancelar.
class MyBookingTile extends ConsumerStatefulWidget {
  const MyBookingTile({super.key, required this.slot});

  final CourtSlot slot;

  @override
  ConsumerState<MyBookingTile> createState() => _MyBookingTileState();
}

class _MyBookingTileState extends ConsumerState<MyBookingTile> {
  bool _busy = false;

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancelar turno',
      message: '¿Cancelar tu reserva? El turno queda libre para otro.',
      confirmLabel: 'Cancelar turno',
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(courtSlotsRepositoryProvider)
          .cancelBooking(widget.slot.id);
      ref.invalidate(myCourtBookingsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final where = [
      slot.courtName,
      slot.clubName,
    ].where((s) => s != null && s.isNotEmpty).join(' · ');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.stadium_outlined),
        title: Text(where.isEmpty ? 'Cancha' : where),
        subtitle: Text(
          '${formatSchedule(slot.start)} – ${formatHour(slot.end)}',
        ),
        trailing: _busy
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                tooltip: 'Cancelar turno',
                icon: const Icon(Icons.close),
                onPressed: _cancel,
              ),
      ),
    );
  }
}
