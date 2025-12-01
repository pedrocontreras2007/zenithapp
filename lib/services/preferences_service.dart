import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _themeKey = 'zenith_theme_dark_mode';

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }
}
