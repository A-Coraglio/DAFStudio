import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../data/chat.dart';
import '../providers/chats_providers.dart';
import 'chat_message_items.dart';
import 'load_older_tile.dart';

/// Reversed message list with "cargar anteriores" pagination. [window] is the
/// polled newest page (50); older pages are fetched on demand with
/// `beforeId` and cached here. Within the window the server state wins
/// (edits/deletes reflect); cached older pages are static history.
class ChatHistory extends ConsumerStatefulWidget {
  const ChatHistory({
    super.key,
    required this.chatId,
    required this.window,
    required this.myUserId,
    required this.controller,
  });

  final int chatId;
  final List<ChatMessage> window;
  final int? myUserId;
  final ScrollController controller;

  @override
  ConsumerState<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends ConsumerState<ChatHistory> {
  static const _page = 50;
  final Map<int, ChatMessage> _older = {};
  bool _loading = false;
  bool _exhausted = false;

  @override
  void didUpdateWidget(ChatHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cached pages belong to one conversation only.
    if (oldWidget.chatId != widget.chatId) {
      _older.clear();
      _exhausted = false;
    }
  }

  List<ChatMessage> _combined() {
    final window = widget.window;
    if (_older.isEmpty) return window;
    final cutoff = window.isEmpty ? null : window.last.id;
    final older =
        _older.values
            .where((m) => cutoff == null || m.id < cutoff)
            .toList()
          ..sort((a, b) => b.id.compareTo(a.id));
    return [...window, ...older];
  }

  Future<void> _loadOlder(int beforeId) async {
    setState(() => _loading = true);
    try {
      final page = await ref
          .read(chatsRepositoryProvider)
          .listMessages(widget.chatId, beforeId: beforeId);
      if (page.length < _page) _exhausted = true;
      for (final m in page) {
        _older[m.id] = m;
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _combined();
    // A full first page means there may be more history behind it.
    final mayHaveMore =
        !_exhausted && messages.isNotEmpty && messages.length >= _page;
    return ListView(
      controller: widget.controller,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        ...chatMessageItems(messages, widget.myUserId),
        if (mayHaveMore)
          LoadOlderTile(
            loading: _loading,
            onTap: () => _loadOlder(messages.last.id),
          ),
      ],
    );
  }
}
