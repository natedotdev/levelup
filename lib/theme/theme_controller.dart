import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeController: singleton + ChangeNotifier
/// - call `await ThemeController.init()` before runApp
/// - read current: `ThemeController.instance.value`
/// - change: `ThemeController.instance.setMode(ThemeMode.dark)`
/// - toggle: `ThemeController.instance.toggle()`
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'themeMode';
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get value => _mode;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == 'dark') {
      instance._mode = ThemeMode.dark;
    } else if (stored == 'system') {
      instance._mode = ThemeMode.system;
    } else {
      instance._mode = ThemeMode.light;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.system ? 'system' : 'light'),
    );
  }

  Future<void> toggle() async {
    // Simple light <-> dark toggle (you can add 'system' in your settings UI)
    await setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> set(ThemeMode temp) async {}
}
