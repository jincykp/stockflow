import 'package:shared_preferences/shared_preferences.dart';

class AuthStateManager {
  static const String AUTH_STATUS_KEY = 'auth_status';
  static const String FIRST_TIME_KEY = 'first_time_user';

  static Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AUTH_STATUS_KEY, true);
    await prefs.setBool(FIRST_TIME_KEY, false);
  }

  static Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AUTH_STATUS_KEY, false);
  }

  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(FIRST_TIME_KEY) ?? true;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AUTH_STATUS_KEY) ?? false;
  }
}
