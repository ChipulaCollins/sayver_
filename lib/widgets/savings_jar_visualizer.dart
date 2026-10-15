import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class SavingsJarVisualizer extends StatelessWidget {
  final SavingsGoal goal;

  const SavingsJarVisualizer({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pct = goal.progressPercentage;
    const primaryColor = AppTheme.warmPeach;
    const accentColor = AppTheme.softCoral;

    final milestones = [
      {'label': '25%', 'title': 'Starter', 'value': 0.25, 'icon': Icons.shield_outlined},
      {'label': '50%', 'title': 'Halfway', 'value': 0.50, 'icon': Icons.bolt_rounded},
      {'label': '75%', 'title': 'Homestretch', 'value': 0.75, 'icon': Icons.local_fire_department_rounded},
      {'label': '100%', 'title': 'Master', 'value': 1.00, 'icon': Icons.emoji_events_rounded},
    ];

    final pace = goal.estimatedDailyPace;
    final paceStr = goal.allowCents
        ? pace.toStringAsFixed(2)
        : pace.toStringAsFixed(0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.mutedSlate.withValues(alpha: 0.92)
                : AppTheme.lightCard.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.military_tech_rounded, size: 18, color: primaryColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'MILESTONE BADGES',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppTheme.textSecondary : AppTheme.mutedSlate,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Daily Pace Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed_rounded, size: 13, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '~${goal.currencySymbol} $paceStr / day',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Milestone Badges Row
              Row(
                children: milestones.map((m) {
                  final targetPct = m['value'] as double;
                  final isUnlocked = pct >= targetPct;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? accentColor.withValues(alpha: 0.18)
                            : (isDark
                                ? AppTheme.darkNavy.withValues(alpha: 0.7)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUnlocked
                              ? accentColor
                              : (isDark
                                  ? AppTheme.borderSlate
                                  : AppTheme.lightBorder),
                          width: isUnlocked ? 1.2 : 0.8,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            m['icon'] as IconData,
                            size: 20,
                            color: isUnlocked
                                ? accentColor
                                : (isDark
                                    ? AppTheme.textSecondary.withValues(alpha: 0.4)
                                    : AppTheme.mutedSlate.withValues(alpha: 0.3)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isUnlocked
                                  ? accentColor
                                  : (isDark
                                      ? AppTheme.textSecondary.withValues(alpha: 0.6)
                                      : AppTheme.mutedSlate.withValues(alpha: 0.6)),
                            ),
                          ),
                          Text(
                            m['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isUnlocked
                                  ? (isDark ? AppTheme.textPrimary : AppTheme.textDark)
                                  : (isDark
                                      ? AppTheme.textSecondary.withValues(alpha: 0.4)
                                      : AppTheme.mutedSlate.withValues(alpha: 0.4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
