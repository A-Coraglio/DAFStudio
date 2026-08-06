import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../courts/providers/courts_providers.dart';
import '../data/admin_user.dart';
import '../providers/admin_providers.dart';

/// Valida y ejecuta el alta de club del panel admin; vuelve atrás y notifica.
Future<void> submitCreateClub(
  BuildContext context,
  WidgetRef ref, {
  required AdminUser? owner,
  required String name,
  required String address,
  required String city,
}) async {
  if (owner == null ||
      name.trim().isEmpty ||
      address.trim().isEmpty ||
      city.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Elegí dueño y completá los datos.')),
    );
    return;
  }
  try {
    await ref.read(adminRepositoryProvider).createClub(
          ownerUserId: owner.userId,
          name: name.trim(),
          address: address.trim(),
          city: city.trim(),
        );
    ref.invalidate(clubsProvider);
    ref.invalidate(myClubsProvider);
    ref.invalidate(adminAuditProvider);
    if (!context.mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Club creado — dueño: ${owner.displayName}')),
    );
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
  }
}
