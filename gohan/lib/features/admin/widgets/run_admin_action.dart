import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/admin_repository.dart';
import '../providers/admin_providers.dart';

/// Esqueleto común de toda acción de admin: confirmación, llamada al repo,
/// invalidación del panel (usuarios + auditoría), snack de éxito y errores
/// amigables. [onDone] suma invalidaciones específicas del caller (p. ej.
/// providers del partido tocado).
Future<void> runAdminAction(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function(AdminRepository repo) op,
  required String successMsg,
  bool destructive = true,
  void Function(WidgetRef ref)? onDone,
}) async {
  final ok = await showConfirmDialog(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    destructive: destructive,
  );
  if (!ok || !context.mounted) return;
  try {
    await op(ref.read(adminRepositoryProvider));
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminAuditProvider);
    onDone?.call(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMsg)));
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
  }
}
