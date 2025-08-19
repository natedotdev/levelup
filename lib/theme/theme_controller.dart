import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeController: holds current ThemeMode and persists it.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._internal(super.mode);

  // Singleton instance
  static late final ThemeController instance;

  /// Call once before runApp()
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode'); // 'light' | 'dark' | 'system'
    final mode = _stringToMode(saved) ?? ThemeMode.light;
    instance = ThemeController._internal(mode);
  }

  Future<void> toggle() async {
    // light -> dark -> light (skip system for simplicity)
    value = (value == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _modeToString(value));
    notifyListeners();
  }

  static ThemeMode? _stringToMode(String? s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }

  static String _modeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
