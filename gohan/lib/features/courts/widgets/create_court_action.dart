import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../providers/courts_providers.dart';

/// Valida y ejecuta el alta de cancha del sheet; cierra y notifica.
/// Devuelve true si terminó (para cortar el estado busy del caller).
Future<void> submitCreateCourt(
  BuildContext context,
  WidgetRef ref, {
  required int clubId,
  required String name,
  required int? sportId,
  required String priceText,
  required bool indoor,
}) async {
  final price = double.tryParse(priceText.trim().replaceAll(',', '.'));
  if (name.trim().isEmpty || sportId == null || price == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completá nombre, deporte y precio.')),
    );
    return;
  }
  try {
    await ref.read(courtsRepositoryProvider).createClubCourt(
          clubId,
          name: name.trim(),
          sportId: sportId,
          pricePerHour: price,
          isIndoor: indoor,
        );
    ref.invalidate(clubCourtsProvider(clubId));
    ref.invalidate(courtsForSportProvider);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancha creada')),
    );
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
  }
}
