import 'package:dio/dio.dart';

import 'chat.dart';

class ChatsRepository {
  ChatsRepository(this._dio);

  final Dio _dio;

  Future<List<Chat>> listMine() async {
    final res = await _dio.get<List<dynamic>>('/api/chats/');
    return res.data!
        .map((e) => Chat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Chat> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/chats/$id/');
    return Chat.fromJson(res.data!);
  }

  Future<Chat> createGeneral({
    String? name,
    required List<int> participantUserIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/chats/',
      data: {
        if (name != null) 'name': name,
        'participant_user_ids': participantUserIds,
      },
    );
    return Chat.fromJson(res.data!);
  }

  Future<Chat> ensureForGame(int gameId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/games/$gameId/chat/',
    );
    return Chat.fromJson(res.data!);
  }

  Future<List<ChatMessage>> listMessages(
    int chatId, {
    int limit = 50,
    int? beforeId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/chats/$chatId/messages/',
      queryParameters: {
        'limit': limit,
        if (beforeId != null) 'before_id': beforeId,
      },
    );
    return res.data!
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> postMessage(int chatId, String content) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/chats/$chatId/messages/',
      data: {'content': content},
    );
    return ChatMessage.fromJson(res.data!);
  }

  /// Moves the user's read cursor to the latest message in [chatId].
  Future<void> markRead(int chatId) async {
    await _dio.post('/api/chats/$chatId/read/');
  }

  /// Total unread messages across all the user's chats — feeds the nav badge.
  Future<int> unreadTotal() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/chats/unread-count/',
    );
    return (res.data?['count'] as int?) ?? 0;
  }
}
