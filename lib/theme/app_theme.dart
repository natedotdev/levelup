import 'package:flutter/material.dart';

/// AppTheme: Light & dark themes using a premium violet seed.
class AppTheme {
  // -----------------------
  // Light Theme
  // -----------------------
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C4AB6),
    brightness: Brightness.light,

    // Gentle violet background (different from card color)
    scaffoldBackgroundColor: const Color(0xFFF8F4FF), // 8-hex ARGB

    cardTheme: const CardThemeData(
      elevation: 2,
      surfaceTintColor: Colors.transparent, // keep color as-is with elevation
      color: Colors.white,
      shadowColor: Color(0x1A000000),       // subtle drop shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  // -----------------------
  // Dark Theme
  // -----------------------
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6C4AB6),
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF0F0F14), // near-black, readable

    cardTheme: const CardThemeData(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      color: Color(0xFF1A1A22),            // darker than scaffold, good contrast
      shadowColor: Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}
