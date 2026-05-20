class Chat {
  final int id;
  final int? gameId;
  final String? name;
  final DateTime createdAt;
  /// Enriched fields from the chat list endpoint — null on single-chat
  /// responses (getById / createGeneral / ensureForGame).
  final String? gameName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.gameId,
    required this.name,
    required this.createdAt,
    this.gameName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'] as int,
        gameId: json['game_id'] as int?,
        name: json['name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        gameName: json['game_name'] as String?,
        lastMessage: json['last_message'] as String?,
        lastMessageAt: switch (json['last_message_at']) {
          final String s => DateTime.parse(s),
          _ => null,
        },
        unreadCount: (json['unread_count'] as int?) ?? 0,
      );

  bool get isGameChat => gameId != null;

  /// Title for the chat list — real game name when available.
  String get displayTitle {
    if (isGameChat) return gameName ?? 'Partido #$gameId';
    return name ?? 'Chat #$id';
  }
}

class ChatMessage {
  final int id;
  final int chatId;
  final int userId;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int,
        chatId: json['chat_id'] as int,
        userId: json['user_id'] as int,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
