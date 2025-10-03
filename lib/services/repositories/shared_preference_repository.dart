import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceRepository {
  static const String keyLogin = 'isLogin';

  static Future<void> setLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLogin, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLogin) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLogin);
  }

  static Future<void> setTheme(bool isLightTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightTheme', isLightTheme);
  }
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLightTheme') ?? true;
  }
}