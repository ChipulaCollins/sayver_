import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/theme/app_theme.dart';

/// Pure mathematical calculation of WCAG 2.1 relative luminance
double wcagRelativeLuminance(Color color) {
  double channelLuminance(int channel) {
    final srgb = channel / 255.0;
    if (srgb <= 0.04045) {
      return srgb / 12.92;
    } else {
      return math.pow((srgb + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  final r = channelLuminance((color.r * 255.0).round().clamp(0, 255));
  final g = channelLuminance((color.g * 255.0).round().clamp(0, 255));
  final b = channelLuminance((color.b * 255.0).round().clamp(0, 255));

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Pure mathematical calculation of WCAG 2.1 contrast ratio
double wcagContrastRatio(Color c1, Color c2) {
  final l1 = wcagRelativeLuminance(c1);
  final l2 = wcagRelativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Empirical Mathematical Contrast Validation (WCAG AA >= 4.5:1)', () {
    test('Calculate exact relative luminances and verify accuracy', () {
      final colors = {
        'darkNavy': AppTheme.darkNavy,
        'mutedSlate': AppTheme.mutedSlate,
        'warmPeach': AppTheme.warmPeach,
        'softCoral': AppTheme.softCoral,
        'elevatedCard': AppTheme.elevatedCard,
        'borderSlate': AppTheme.borderSlate,
        'textPrimary': AppTheme.textPrimary,
        'textSecondary': AppTheme.textSecondary,
        'textDark': AppTheme.textDark,
        'lightCard': AppTheme.lightCard,
        'lightBorder': AppTheme.lightBorder,
        'lightSurface': AppTheme.lightSurface,
        'lightBg': AppTheme.lightBg,
      };

      for (final entry in colors.entries) {
        final pureMathL = wcagRelativeLuminance(entry.value);
        final flutterL = entry.value.computeLuminance();
        expect(
          (pureMathL - flutterL).abs(),
          lessThan(0.005),
          reason: 'Luminance mismatch for ${entry.key}',
        );
      }
    });

    test('1. textDark against warmPeach, softCoral, lightSurface, lightCard', () {
      final pairs = <String, Color>{
        'warmPeach': AppTheme.warmPeach,
        'softCoral': AppTheme.softCoral,
        'lightSurface': AppTheme.lightSurface,
        'lightCard': AppTheme.lightCard,
        'lightBg': AppTheme.lightBg,
      };

      for (final entry in pairs.entries) {
        final ratio = wcagContrastRatio(AppTheme.textDark, entry.value);
        final appThemeRatio = AppTheme.calculateContrastRatio(AppTheme.textDark, entry.value);

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'textDark on ${entry.key} MUST satisfy WCAG AA (>= 4.5:1), got ${ratio.toStringAsFixed(2)}:1',
        );
        expect(
          (ratio - appThemeRatio).abs(),
          lessThan(0.05),
          reason: 'AppTheme.calculateContrastRatio mismatch for textDark on ${entry.key}',
        );
      }
    });

    test('2. textPrimary against darkNavy, mutedSlate, elevatedCard', () {
      final pairs = <String, Color>{
        'darkNavy': AppTheme.darkNavy,
        'mutedSlate': AppTheme.mutedSlate,
        'elevatedCard': AppTheme.elevatedCard,
      };

      for (final entry in pairs.entries) {
        final ratio = wcagContrastRatio(AppTheme.textPrimary, entry.value);
        final appThemeRatio = AppTheme.calculateContrastRatio(AppTheme.textPrimary, entry.value);

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'textPrimary on ${entry.key} MUST satisfy WCAG AA (>= 4.5:1), got ${ratio.toStringAsFixed(2)}:1',
        );
        expect(
          (ratio - appThemeRatio).abs(),
          lessThan(0.05),
          reason: 'AppTheme.calculateContrastRatio mismatch for textPrimary on ${entry.key}',
        );
      }
    });

    test('3. Verification of low-contrast combinations and defensive restrictions', () {
      final peachOnLight = wcagContrastRatio(AppTheme.warmPeach, AppTheme.lightSurface);
      final coralOnLight = wcagContrastRatio(AppTheme.softCoral, AppTheme.lightSurface);
      final peachOnCard = wcagContrastRatio(AppTheme.warmPeach, AppTheme.lightCard);

      // Confirm they fail AA, proving that using textDark on these backgrounds is mandatory
      expect(peachOnLight, lessThan(4.5));
      expect(coralOnLight, lessThan(4.5));
      expect(peachOnCard, lessThan(4.5));
    });

    test('4. textSecondary contrast checks on dark and light surfaces', () {
      final secOnSlate = wcagContrastRatio(AppTheme.textSecondary, AppTheme.mutedSlate);
      final secOnNavy = wcagContrastRatio(AppTheme.textSecondary, AppTheme.darkNavy);
      final secOnCard = wcagContrastRatio(AppTheme.textSecondary, AppTheme.elevatedCard);

      expect(secOnSlate, greaterThanOrEqualTo(4.5));
      expect(secOnNavy, greaterThanOrEqualTo(4.5));
      expect(secOnCard, greaterThanOrEqualTo(4.5));
    });

    test('5. AppTheme adaptive color helper contract tests', () {
      expect(AppTheme.contrastText(AppTheme.warmPeach), equals(AppTheme.textDark));
      expect(AppTheme.contrastText(AppTheme.softCoral), equals(AppTheme.textDark));
      expect(AppTheme.contrastText(AppTheme.lightSurface), equals(AppTheme.textDark));
      expect(AppTheme.contrastText(AppTheme.lightCard), equals(AppTheme.textDark));
      expect(AppTheme.contrastText(AppTheme.darkNavy), equals(AppTheme.textPrimary));
      expect(AppTheme.contrastText(AppTheme.mutedSlate), equals(AppTheme.textPrimary));
      expect(AppTheme.contrastText(AppTheme.elevatedCard), equals(AppTheme.textPrimary));
    });

    test('6. ThemeData Light and Dark integrity inspection', () {
      final dark = AppTheme.darkTheme;
      final light = AppTheme.lightTheme;

      // Dark theme checks
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, AppTheme.warmPeach);
      expect(dark.colorScheme.onPrimary, AppTheme.textDark);
      expect(dark.colorScheme.surface, AppTheme.mutedSlate);
      expect(dark.colorScheme.onSurface, AppTheme.textPrimary);
      expect(dark.scaffoldBackgroundColor, AppTheme.darkNavy);

      // Light theme checks
      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, AppTheme.darkNavy);
      expect(light.colorScheme.onPrimary, Colors.white);
      expect(light.colorScheme.surface, AppTheme.lightSurface);
      expect(light.colorScheme.onSurface, AppTheme.textDark);
      expect(light.scaffoldBackgroundColor, AppTheme.lightBg);
    });
  });
}
