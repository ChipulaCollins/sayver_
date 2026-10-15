import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sayver Design System & App Theme
///
/// Implements high-density dynamic Grok Hub aesthetic with strict brand colors:
/// - `#312C51` Deep Navy (Scaffold & deep surface)
/// - `#48426D` Muted Slate (Cards, dialogs, containers)
/// - `#F0C38E` Warm Peach (Primary highlight, action buttons, active gauges)
/// - `#F1AA9B` Soft Coral (Secondary accent, badges, FAB)
///
/// WCAG AA Compliance:
/// - In Light mode, bare warm peach text is strictly prohibited on light surfaces.
/// - Text on light backgrounds enforces `textDark` (`#231E3D`) or `darkNavy` (`#312C51`) for 12:1+ contrast.
/// - Text on `warmPeach` or `softCoral` elements uses `textDark` for 8:1+ contrast.
/// - Complete Plus Jakarta Sans typographic scale configured for both themes.
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
  static const Color lightCard = Color(0xFFF4EFFB);
  static const Color lightBorder = Color(0xFFD8D1E8);

  // --- WCAG AA Contrast Helpers ---

  /// Calculates the WCAG contrast ratio between two colors (ranging from 1.0 to 21.0)
  static double calculateContrastRatio(Color c1, Color c2) {
    final l1 = c1.computeLuminance();
    final l2 = c2.computeLuminance();
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns high-contrast text color (`textDark` or `textPrimary`) for any background
  static Color contrastText(Color background) {
    final lum = background.computeLuminance();
    return lum > 0.35 ? textDark : textPrimary;
  }

  /// Adaptive text color based on active theme brightness
  static Color adaptiveTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimary
        : textDark;
  }

  /// Adaptive secondary/subtitle text color based on active theme brightness
  static Color adaptiveSubtextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondary
        : mutedSlate;
  }

  /// Adaptive card surface color based on active theme brightness
  static Color adaptiveCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? elevatedCard
        : lightCard;
  }

  /// Adaptive container/sheet surface color based on active theme brightness
  static Color adaptiveSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? mutedSlate
        : lightSurface;
  }

  /// Adaptive border color based on active theme brightness
  static Color adaptiveBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderSlate
        : lightBorder;
  }

  /// Adaptive scaffold background color based on active theme brightness
  static Color adaptiveScaffoldColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkNavy
        : lightBg;
  }

  // --- Typography Builder ---

  static TextTheme _buildTextTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor,
    required Color mutedColor,
  }) {
    final base = ThemeData(brightness: brightness).textTheme;
    final fontTheme = GoogleFonts.plusJakartaSansTextTheme(base);

    return fontTheme.copyWith(
      displayLarge: fontTheme.displayLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displayMedium: fontTheme.displayMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: fontTheme.displaySmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: fontTheme.headlineLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      headlineMedium: fontTheme.headlineMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: fontTheme.headlineSmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: fontTheme.titleLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: fontTheme.titleMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: fontTheme.titleSmall?.copyWith(
        color: secondaryColor,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: fontTheme.bodyLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: fontTheme.bodyMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: fontTheme.bodySmall?.copyWith(
        color: secondaryColor,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: fontTheme.labelLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: fontTheme.labelMedium?.copyWith(
        color: secondaryColor,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: fontTheme.labelSmall?.copyWith(
        color: mutedColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // --- Themes ---

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(
      brightness: Brightness.dark,
      primaryColor: textPrimary,
      secondaryColor: textSecondary,
      mutedColor: textSecondary.withValues(alpha: 0.7),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkNavy,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: warmPeach,
        onPrimary: textDark,
        primaryContainer: elevatedCard,
        onPrimaryContainer: textPrimary,
        secondary: softCoral,
        onSecondary: textDark,
        secondaryContainer: mutedSlate,
        onSecondaryContainer: textPrimary,
        tertiary: warmPeach,
        onTertiary: textDark,
        surface: mutedSlate,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: borderSlate,
        outlineVariant: borderSlate,
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
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
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: mutedSlate,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: mutedSlate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: borderSlate, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmPeach,
          foregroundColor: textDark,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warmPeach,
          side: const BorderSide(color: borderSlate, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: warmPeach,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevatedCard,
        selectedColor: warmPeach,
        disabledColor: elevatedCard.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          color: textDark,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: borderSlate, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
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
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: borderSlate,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      brightness: Brightness.light,
      primaryColor: textDark,
      secondaryColor: mutedSlate,
      mutedColor: borderSlate,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: darkNavy,
        onPrimary: Colors.white,
        primaryContainer: lightCard,
        onPrimaryContainer: textDark,
        secondary: mutedSlate,
        onSecondary: Colors.white,
        secondaryContainer: lightCard,
        onSecondaryContainer: textDark,
        tertiary: darkNavy,
        onTertiary: Colors.white,
        surface: lightSurface,
        onSurface: textDark,
        onSurfaceVariant: mutedSlate,
        outline: lightBorder,
        outlineVariant: lightBorder,
        error: Color(0xFFDC2626),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shadowColor: darkNavy.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: mutedSlate,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkNavy,
          foregroundColor: textPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkNavy,
          side: const BorderSide(color: darkNavy, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkNavy,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCard,
        selectedColor: darkNavy,
        disabledColor: lightCard.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: textDark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: lightBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: mutedSlate),
        hintStyle: TextStyle(color: mutedSlate.withValues(alpha: 0.7)),
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
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
    );
  }
}


