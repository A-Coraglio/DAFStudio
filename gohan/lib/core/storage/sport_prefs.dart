import 'package:shared_preferences/shared_preferences.dart';

/// Persists the active sport chosen in the home selector so it survives
/// app restarts.
class SportPrefs {
  static const _key = 'active_sport_id';

  static Future<int?> readActiveSport() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_key);
  }

  static Future<void> writeActiveSport(int id) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_key, id);
  }
}
