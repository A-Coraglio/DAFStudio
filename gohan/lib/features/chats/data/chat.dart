class Chat {
  final int id;
  final int? gameId;
  final String? name;
  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.gameId,
    required this.name,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'] as int,
        gameId: json['game_id'] as int?,
        name: json['name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool get isGameChat => gameId != null;
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
