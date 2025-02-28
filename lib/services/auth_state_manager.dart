import 'package:shared_preferences/shared_preferences.dart';

class AuthStateManager {
  static const String AUTH_STATUS_KEY = 'auth_status';
  static const String FIRST_TIME_KEY = 'first_time_user';

  static Future<bool> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Save both states and check if they were saved successfully
    final authStatus = await prefs.setBool(AUTH_STATUS_KEY, true);
    final firstTimeStatus = await prefs.setBool(FIRST_TIME_KEY, false);

    // Verify the states were saved correctly
    final isLoggedInNow = await isLoggedIn();
    print("Login state after setting: $isLoggedInNow");

    return authStatus && firstTimeStatus;
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
