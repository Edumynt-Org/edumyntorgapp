import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString('theme_mode');
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await _prefs.setString('theme_mode', 'light');
    } else if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await _prefs.setString('theme_mode', 'dark');
    } else {
      // If system, toggle to opposite of what system currently is
      final isCurrentlyDark = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
      if (isCurrentlyDark) {
        _themeMode = ThemeMode.light;
        await _prefs.setString('theme_mode', 'light');
      } else {
        _themeMode = ThemeMode.dark;
        await _prefs.setString('theme_mode', 'dark');
      }
    }
    notifyListeners();
  }
}
