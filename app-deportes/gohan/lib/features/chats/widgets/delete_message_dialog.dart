import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat.dart';
import '../providers/chats_providers.dart';
import '../../../core/errors/error_snackbar.dart';

/// Confirmation dialog for deleting an own message. Hard delete — the
/// bubble disappears for everyone.
class DeleteMessageDialog extends ConsumerStatefulWidget {
  const DeleteMessageDialog({super.key, required this.message});

  final ChatMessage message;

  static Future<void> show(BuildContext context, ChatMessage message) {
    return showDialog(
      context: context,
      builder: (_) => DeleteMessageDialog(message: message),
    );
  }

  @override
  ConsumerState<DeleteMessageDialog> createState() =>
      _DeleteMessageDialogState();
}

class _DeleteMessageDialogState extends ConsumerState<DeleteMessageDialog> {
  bool _deleting = false;

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await ref
          .read(chatsRepositoryProvider)
          .deleteMessage(widget.message.chatId, widget.message.id);
      ref.invalidate(chatMessagesStreamProvider(widget.message.chatId));
      ref.invalidate(myChatsProvider); // last-message preview may change
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Eliminar mensaje?'),
      content: const Text('Se borra para todos y no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _deleting ? null : _delete,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
