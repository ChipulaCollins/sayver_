import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class CelebrationDialog extends StatelessWidget {
  final SavingsGoal goal;

  const CelebrationDialog({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = AppTheme.warmPeach;

    final amtStr = goal.allowCents
        ? goal.targetAmount.toStringAsFixed(2)
        : goal.targetAmount.toStringAsFixed(0);

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = (screenHeight - 32).clamp(360.0, 680.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.mutedSlate.withValues(alpha: 0.94)
                    : AppTheme.lightSurface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(26),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 60,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '🎉 GOAL COMPLETED! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You successfully saved ${goal.currencySymbol}$amtStr for "${goal.title}"!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.mutedSlate,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkNavy.withValues(alpha: 0.6)
                            : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _VictoryMetric(
                            label: 'TOTAL SAVED',
                            value: '${goal.currencySymbol}$amtStr',
                            accentColor: accentColor,
                            isDark: isDark,
                          ),
                          Container(
                            height: 32,
                            width: 0.8,
                            color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                          ),
                          _VictoryMetric(
                            label: 'ENVELOPES',
                            value: '${goal.segmentCount}',
                            accentColor: accentColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: AppTheme.textDark,
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VictoryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final bool isDark;

  const _VictoryMetric({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
