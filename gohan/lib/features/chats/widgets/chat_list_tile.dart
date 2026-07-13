import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../data/chat.dart';

/// One row of the chat list — title, last-message preview and last-activity
/// time. Unread chats are bolded and carry a count badge (WhatsApp-style).
class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.chat, required this.onTap});

  final Chat chat;
  final VoidCallback onTap;

  String get _preview {
    final m = chat.lastMessage;
    return (m == null || m.isEmpty) ? 'Sin mensajes todavía' : m;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final at = chat.lastMessageAt;
    final hasUnread = chat.unreadCount > 0;
    return ListTile(
      leading: CircleAvatar(
        child: Icon(chat.isGameChat ? Icons.sports : Icons.chat),
      ),
      title: Text(
        chat.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        _preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: hasUnread
            ? TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500)
            : null,
      ),
      trailing: (at == null && !hasUnread)
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (at != null)
                  Text(
                    formatListTime(at),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: hasUnread ? scheme.primary : null,
                    ),
                  ),
                if (hasUnread) ...[
                  const SizedBox(height: 4),
                  _UnreadBadge(count: chat.unreadCount),
                ],
              ],
            ),
      onTap: onTap,
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
