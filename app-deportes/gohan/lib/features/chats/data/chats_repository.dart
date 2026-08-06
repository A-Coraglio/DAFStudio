import 'package:dio/dio.dart';

import '../../../core/http/response_data.dart';
import 'chat.dart';

class ChatsRepository {
  ChatsRepository(this._dio);

  final Dio _dio;

  Future<List<Chat>> listMine() async {
    final res = await _dio.get<List<dynamic>>('/api/chats/');
    return requireData(res)
        .map((e) => Chat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Chat> getById(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/chats/$id/');
    return Chat.fromJson(requireData(res));
  }

  // createGeneral se eliminó (2026-07-21): el backend deshabilitó
  // POST /api/chats/ hasta que exista el modelo social con invitaciones.

  Future<Chat> ensureForGame(int gameId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/games/$gameId/chat/',
    );
    return Chat.fromJson(requireData(res));
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
    return requireData(res)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> postMessage(int chatId, String content) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/chats/$chatId/messages/',
      data: {'content': content},
    );
    return ChatMessage.fromJson(requireData(res));
  }

  /// Edits an own message. Backend rejects with 403 if the caller isn't
  /// the author.
  Future<ChatMessage> updateMessage(
    int chatId,
    int messageId,
    String content,
  ) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/chats/$chatId/messages/$messageId/',
      data: {'content': content},
    );
    return ChatMessage.fromJson(requireData(res));
  }

  /// Deletes an own message (hard delete).
  Future<void> deleteMessage(int chatId, int messageId) async {
    await _dio.delete('/api/chats/$chatId/messages/$messageId/');
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
