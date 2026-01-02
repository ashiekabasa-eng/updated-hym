import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme selection (light/dark) and persistence across app sessions.
class ThemeService {
  static const String _themeKey = 'app_theme_mode';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;

  /// Initialize the theme service with SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final themeModeString = _prefs.getString(_themeKey) ?? 'light';
    _themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  /// Get current theme mode
  ThemeMode getThemeMode() => _themeMode;

  /// Check if dark mode is enabled
  bool isDarkMode() => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await _prefs.setString(
      _themeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(
      _themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
