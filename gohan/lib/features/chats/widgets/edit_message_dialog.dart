import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../data/chat.dart';
import '../providers/chats_providers.dart';

/// Dialog to edit an own message. Saves via PATCH and refreshes the
/// messages stream + chat list preview.
class EditMessageDialog extends ConsumerStatefulWidget {
  const EditMessageDialog({super.key, required this.message});

  final ChatMessage message;

  static Future<void> show(BuildContext context, ChatMessage message) {
    return showDialog(
      context: context,
      builder: (_) => EditMessageDialog(message: message),
    );
  }

  @override
  ConsumerState<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends ConsumerState<EditMessageDialog> {
  late final _controller = TextEditingController(text: widget.message.content);
  bool _saving = false;

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(chatsRepositoryProvider)
          .updateMessage(widget.message.chatId, widget.message.id, text);
      ref.invalidate(chatMessagesStreamProvider(widget.message.chatId));
      ref.invalidate(myChatsProvider); // last-message preview may change
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dioErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar mensaje'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: 4,
        maxLength: 2000,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
