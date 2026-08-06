import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around `SharedPreferences` for the game-mode memory used
/// across create-game, matchmaking and feed filter. Keeps keys in one place
/// so a future rename doesn't drift across features.
class ModePrefs {
  static const _createKey = 'last_create_mode';
  static const _matchmakingKey = 'last_matchmaking_mode';
  static const _feedFilterKey = 'feed_mode_filter';

  static Future<String?> readLastCreateMode() => _readString(_createKey);
  static Future<void> writeLastCreateMode(String value) =>
      _writeString(_createKey, value);

  static Future<String?> readLastMatchmakingMode() =>
      _readString(_matchmakingKey);
  static Future<void> writeLastMatchmakingMode(String value) =>
      _writeString(_matchmakingKey, value);

  /// Null means "Todos" (no filter).
  static Future<String?> readFeedFilter() => _readString(_feedFilterKey);
  static Future<void> writeFeedFilter(String? value) async {
    final p = await SharedPreferences.getInstance();
    if (value == null) {
      await p.remove(_feedFilterKey);
    } else {
      await p.setString(_feedFilterKey, value);
    }
  }

  static Future<String?> _readString(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(key);
  }

  static Future<void> _writeString(String key, String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, value);
  }
}
