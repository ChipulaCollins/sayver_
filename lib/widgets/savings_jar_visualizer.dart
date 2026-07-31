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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.mutedSlate : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech_rounded, size: 18, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'MILESTONE BADGES',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppTheme.textSecondary : Colors.black54,
                    ),
                  ),
                ],
              ),

              // Daily Pace Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
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
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? accentColor.withValues(alpha: 0.2)
                        : (isDark ? AppTheme.darkNavy : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isUnlocked
                          ? accentColor
                          : (isDark
                              ? AppTheme.borderSlate
                              : AppTheme.lightBorder),
                      width: isUnlocked ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        m['icon'] as IconData,
                        size: 20,
                        color: isUnlocked
                            ? accentColor
                            : (isDark ? AppTheme.textSecondary.withValues(alpha: 0.4) : Colors.black26),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked
                              ? accentColor
                              : (isDark ? AppTheme.textSecondary.withValues(alpha: 0.5) : Colors.black38),
                        ),
                      ),
                      Text(
                        m['title'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked
                              ? (isDark ? AppTheme.textPrimary : const Color(0xFF231E3D))
                              : (isDark ? AppTheme.textSecondary.withValues(alpha: 0.4) : Colors.black26),
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
    );
  }
}

