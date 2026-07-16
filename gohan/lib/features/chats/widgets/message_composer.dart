import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chats_providers.dart';
import '../../../core/errors/error_snackbar.dart';

/// Text field + send button pinned at the bottom of a chat panel. Invalidates
/// the messages stream after a successful send so the new message shows up
/// immediately without waiting for the poll tick. On hardware keyboards
/// Enter sends and Shift+Enter inserts a newline.
class MessageComposer extends ConsumerStatefulWidget {
  const MessageComposer({super.key, required this.chatId, this.onSent});

  final int chatId;
  final VoidCallback? onSent;

  @override
  ConsumerState<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends ConsumerState<MessageComposer> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatsRepositoryProvider).postMessage(widget.chatId, text);
      _controller.clear();
      ref.invalidate(chatMessagesStreamProvider(widget.chatId));
      widget.onSent?.call();
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // Physical keyboards only (web/desktop): Enter sends, Shift+Enter falls
    // through to the TextField and inserts the newline.
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Focus(
                onKeyEvent: _onKey,
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Escribí un mensaje...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
