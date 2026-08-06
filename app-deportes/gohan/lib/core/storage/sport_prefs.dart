import 'package:shared_preferences/shared_preferences.dart';

/// Persists the active sport chosen in the home selector so it survives app
/// restarts.
///
/// Keyed per user id: switching accounts on the same device must not leak one
/// user's last-selected sport into another's session, and a user who has never
/// touched the selector falls back to their profile favorite (see
/// `ActiveSportIdNotifier`) instead of inheriting whatever the previous user
/// picked.
class SportPrefs {
  static const _keyPrefix = 'active_sport_id';

  static String _key(int userId) => '${_keyPrefix}_$userId';

  static Future<int?> readActiveSport(int userId) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_key(userId));
  }

  static Future<void> writeActiveSport(int userId, int id) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_key(userId), id);
  }
}
