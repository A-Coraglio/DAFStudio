import 'package:flutter/material.dart';

import '../data/chat.dart';
import 'chat_day_separator.dart';
import 'message_bubble.dart';

/// Newest-first bubbles with a day pill above the oldest message of each day
/// (in a reversed list that means: appended after it). Shared row builder of
/// the chat history list.
List<Widget> chatMessageItems(List<ChatMessage> messages, int? myUserId) {
  bool sameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  final items = <Widget>[];
  for (var i = 0; i < messages.length; i++) {
    items.add(
      MessageBubble(message: messages[i], mine: messages[i].userId == myUserId),
    );
    final lastOfDay =
        i == messages.length - 1 ||
        !sameDay(messages[i].createdAt, messages[i + 1].createdAt);
    if (lastOfDay) {
      items.add(ChatDaySeparator(day: messages[i].createdAt));
    }
  }
  return items;
}
