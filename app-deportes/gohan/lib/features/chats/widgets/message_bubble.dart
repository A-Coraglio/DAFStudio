import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../data/chat.dart';
import 'message_actions_sheet.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = mine ? scheme.primary : scheme.surfaceContainerHighest;
    final fg = mine ? scheme.onPrimary : scheme.onSurface;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        // Own messages: long-press opens editar/eliminar.
        onLongPress: mine
            ? () => MessageActionsSheet.show(context, message)
            : null,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            // Asymmetric: the corner pointing at the sender stays sharp.
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Group chats: say who's talking. Tap → their public profile.
              if (!mine && message.authorName != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: message.authorPlayerId == null
                        ? null
                        : () => context.push(
                            '/players/${message.authorPlayerId}',
                          ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        message.authorName!,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              Text(message.content, style: TextStyle(color: fg)),
              const SizedBox(height: 2),
              Text(
                (message.updatedAt != null ? 'editado · ' : '') +
                    formatMessageTime(message.createdAt),
                style: TextStyle(color: fg.withValues(alpha: .6), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
