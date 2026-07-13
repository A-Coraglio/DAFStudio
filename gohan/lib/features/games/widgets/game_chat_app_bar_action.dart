import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_client.dart';
import '../../chats/providers/chats_providers.dart';

/// AppBar icon that opens the game's chat. Same `ensureForGame` behavior as
/// [GameChatButton] but rendered compact so the detail screen's body keeps a
/// clear primary/secondary button hierarchy.
class GameChatAppBarAction extends ConsumerStatefulWidget {
  const GameChatAppBarAction({super.key, required this.gameId});

  final int gameId;

  @override
  ConsumerState<GameChatAppBarAction> createState() =>
      _GameChatAppBarActionState();
}

class _GameChatAppBarActionState extends ConsumerState<GameChatAppBarAction> {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dioErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Chat del partido',
      onPressed: _loading ? null : _open,
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chat_bubble_outline),
    );
  }
}
