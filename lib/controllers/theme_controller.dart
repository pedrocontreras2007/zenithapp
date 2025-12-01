import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferencesService) {
    _loadTheme();
  }

  final PreferencesService _preferencesService;
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    _isDarkMode = await _preferencesService.loadDarkMode();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _preferencesService.saveDarkMode(value);
  }
}
