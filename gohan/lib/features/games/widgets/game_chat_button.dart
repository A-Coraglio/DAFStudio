import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../chats/providers/chats_providers.dart';

/// Navigates to the game's chat. First hit auto-creates the chat row via
/// `ensureForGame`, so from the user's POV the chat is always "there".
class GameChatButton extends ConsumerStatefulWidget {
  const GameChatButton({super.key, required this.gameId});

  final int gameId;

  @override
  ConsumerState<GameChatButton> createState() => _GameChatButtonState();
}

class _GameChatButtonState extends ConsumerState<GameChatButton> {
  bool _loading = false;

  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      final chat = await ref
          .read(chatsRepositoryProvider)
          .ensureForGame(widget.gameId);
      if (!mounted) return;
      context.push('/chats/${chat.id}');
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _open,
      icon: const Icon(Icons.chat_bubble_outline),
      label: Text(_loading ? 'Abriendo...' : 'Chat del partido'),
    );
  }
}
