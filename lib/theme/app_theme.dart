import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - User Requested Palette & UI Logic Assignments
  static const Color darkNavy = Color(0xFF312C51);     // Primary Scaffold & App Deep Background
  static const Color mutedSlate = Color(0xFF48426D);   // Card Surfaces, AppBars, Containers & Dialogs
  static const Color warmPeach = Color(0xFFF0C38E);    // Primary Accent, Golden Highlights, Main Action Buttons & Gauges
  static const Color softCoral = Color(0xFFF1AA9B);    // Secondary Accent, Badges, Micro-accents & FABs

  // Derived Surface & Hierarchy Colors
  static const Color elevatedCard = Color(0xFF3D375B);  // Lighter slate for inner cards
  static const Color borderSlate = Color(0xFF5A5282);   // Modern subtle card borders
  static const Color textPrimary = Color(0xFFFAF8FC);   // Crisp off-white for high legibility
  static const Color textSecondary = Color(0xFFC7C2E0); // Soft lavender gray for subtitles
  static const Color textDark = Color(0xFF231E3D);      // Dark text on top of bright Peach/Coral buttons

  // Legacy mappings for full backward compatibility
  static const Color primaryEmerald = warmPeach;
  static const Color accentCyan = softCoral;
  static const Color accentGold = warmPeach;
  static const Color accentRose = softCoral;
  static const Color accentPurple = Color(0xFF7A6DA0);

  static const Color darkBg = darkNavy;
  static const Color darkSurface = mutedSlate;
  static const Color darkCard = elevatedCard;
  static const Color darkBorder = borderSlate;

  static const Color lightBg = Color(0xFFF4EFF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEBE4F2);
  static const Color lightBorder = Color(0xFFD3C8E4);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkNavy,
      colorScheme: const ColorScheme.dark(
        primary: warmPeach,
        secondary: softCoral,
        tertiary: warmPeach,
        surface: mutedSlate,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: elevatedCard,
        elevation: 2,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSlate, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: mutedSlate,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderSlate, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmPeach, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: softCoral,
        foregroundColor: textDark,
        elevation: 4,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: darkNavy,
        secondary: softCoral,
        tertiary: warmPeach,
        surface: lightSurface,
        onSurface: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkNavy, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkNavy,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

