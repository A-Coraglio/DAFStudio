import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/format/dates.dart';
import '../data/court_slot.dart';
import '../providers/courts_providers.dart';

/// Turno visto por quien administra la cancha: estado + quién reservó +
/// acciones (bloquear / liberar / quitar).
class ManageSlotTile extends ConsumerWidget {
  const ManageSlotTile({super.key, required this.slot});

  final CourtSlot slot;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() op,
    String msg,
  ) async {
    try {
      await op();
      ref.invalidate(courtSlotsProvider(slot.courtId));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(courtSlotsRepositoryProvider);
    final (label, color) = switch (slot.status) {
      'free' => ('Libre', scheme.primary),
      'booked' => ('Reservado', scheme.tertiary),
      _ => ('Ocupado', scheme.error),
    };
    return ListTile(
      dense: true,
      title: Text('${formatSchedule(slot.start)} – ${formatHour(slot.end)}'),
      subtitle: Text(
        slot.isBooked && slot.bookedByName != null
            ? '$label · ${slot.bookedByName}'
            : label,
        style: TextStyle(color: color),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (a) => switch (a) {
          'block' => _run(context, ref, () => repo.block(slot.id),
              'Turno marcado como ocupado'),
          'free' => _run(
              context, ref, () => repo.free(slot.id), 'Turno liberado'),
          'delete' => _run(
              context, ref, () => repo.delete(slot.id), 'Turno eliminado'),
          _ => null,
        },
        itemBuilder: (_) => [
          if (!slot.isBlocked)
            const PopupMenuItem(
              value: 'block', child: Text('Marcar ocupado'),
            ),
          if (!slot.isFree)
            const PopupMenuItem(value: 'free', child: Text('Liberar')),
          if (!slot.isBooked)
            const PopupMenuItem(value: 'delete', child: Text('Quitar turno')),
        ],
      ),
    );
  }
}
