import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const _sportKey = 'preferred_sport';

  static Future<void> setSport(String sport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sportKey, sport);
  }

  static Future<String?> getSport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sportKey);
  }
}
