import 'package:flutter/material.dart';

import '../data/chat.dart';
import 'delete_message_dialog.dart';
import 'edit_message_dialog.dart';

/// Bottom sheet shown on long-press over an own bubble. Only picks the
/// action — the edit/delete dialogs do the actual work.
class MessageActionsSheet extends StatelessWidget {
  const MessageActionsSheet._();

  static Future<void> show(BuildContext context, ChatMessage message) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const MessageActionsSheet._(),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'edit':
        await EditMessageDialog.show(context, message);
      case 'delete':
        await DeleteMessageDialog.show(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar mensaje'),
            onTap: () => Navigator.of(context).pop('edit'),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Eliminar mensaje',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    );
  }
}
