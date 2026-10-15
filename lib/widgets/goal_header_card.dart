import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class GoalHeaderCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onSurprisePick;
  final VoidCallback onAutoDeposit;
  final VoidCallback onShuffleSegments;
  final VoidCallback onEditGoal;
  final VoidCallback? onViewInsights;

  const GoalHeaderCard({
    super.key,
    required this.goal,
    required this.onSurprisePick,
    required this.onAutoDeposit,
    required this.onShuffleSegments,
    required this.onEditGoal,
    this.onViewInsights,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percent = (goal.progressPercentage * 100).toStringAsFixed(0);

    final savedStr = goal.allowCents
        ? goal.savedAmount.toStringAsFixed(2)
        : goal.savedAmount.toStringAsFixed(0);
    final targetStr = goal.allowCents
        ? goal.targetAmount.toStringAsFixed(2)
        : goal.targetAmount.toStringAsFixed(0);
    final remainingStr = goal.allowCents
        ? goal.remainingAmount.toStringAsFixed(2)
        : goal.remainingAmount.toStringAsFixed(0);

    final pace = goal.estimatedDailyPace;
    final paceStr = goal.allowCents ? pace.toStringAsFixed(2) : pace.toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.mutedSlate.withValues(alpha: 0.55) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSlate.withValues(alpha: 0.6)
              : AppTheme.lightBorder.withValues(alpha: 0.7),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxMetricWidth = constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header eyebrow: Category & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.warmPeach,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        '${goal.category.toUpperCase()} • ${goal.completedCount}/${goal.segmentCount} SAVED',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isDark ? AppTheme.textSecondary : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Percentage Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.warmPeach.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.warmPeach.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.warmPeach,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Hero Big Typography Amount
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${goal.currencySymbol} $savedStr',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: isDark ? AppTheme.textPrimary : const Color(0xFF231E3D),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'of ${goal.currencySymbol} $targetStr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textSecondary : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sleek Glowing Progress Line
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: isDark
                      ? AppTheme.darkNavy.withValues(alpha: 0.8)
                      : AppTheme.lightCard,
                ),
                FractionallySizedBox(
                  widthFactor: goal.progressPercentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.warmPeach,
                          AppTheme.softCoral,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warmPeach.withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Sub-metrics Pill Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxMetricWidth),
                child: Text(
                  'Remaining: ${goal.currencySymbol} $remainingStr',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textSecondary : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxMetricWidth),
                child: InkWell(
                  onTap: onViewInsights,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 13,
                            color: AppTheme.warmPeach.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${goal.currencySymbol} $paceStr/day',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.warmPeach,
                            ),
                          ),
                          if (onViewInsights != null) ...[
                            const SizedBox(width: 3),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: isDark ? AppTheme.textSecondary : Colors.black45,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  ),
);
  }
}
