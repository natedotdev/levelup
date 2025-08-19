import 'package:flutter/material.dart';

/// AppTheme: light & dark themes using a premium violet seed.
/// Keep this minimal to avoid SDK type mismatches.
class AppTheme {
  // -------------------------
  // Light Theme
  // -------------------------
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C4AB6),
    brightness: Brightness.light,
    // 8-hex ARGB color (no lint)
    scaffoldBackgroundColor: const Color(0xFFF8F4FF),
  );

  // -------------------------
  // Dark Theme
  // -------------------------
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C4AB6),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F14),
  );
}
