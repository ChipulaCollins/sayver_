import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class AnalyticsView extends StatelessWidget {
  final SavingsGoal goal;

  const AnalyticsView({
    super.key,
    required this.goal,
  });

  int _calculateStreak() {
    final completed = goal.segments
        .where((s) => s.isCompleted && s.completedAt != null)
        .toList();
    if (completed.isEmpty) return 0;

    final Set<String> daysSaved = {};
    for (var s in completed) {
      daysSaved.add(DateFormat('yyyy-MM-dd').format(s.completedAt!));
    }

    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      if (daysSaved.contains(dateStr)) {
        streak++;
      } else {
        if (i == 0) continue;
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completedSegments = goal.segments.where((s) => s.isCompleted).toList();
    completedSegments.sort((a, b) => (b.completedAt ?? DateTime.now())
        .compareTo(a.completedAt ?? DateTime.now()));

    final streak = _calculateStreak();

    double maxSeg = 0.0;
    double minSeg = 0.0;
    double avgSeg = 0.0;

    if (goal.segments.isNotEmpty) {
      final amounts = goal.segments.map((s) => s.amount).toList();
      amounts.sort();
      minSeg = amounts.first;
      maxSeg = amounts.last;
      avgSeg = goal.targetAmount / goal.segmentCount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Metrics Grid with Palette Highlights
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppTheme.warmPeach,
                label: 'SAVING STREAK',
                value: '$streak Days',
                subText: streak > 0 ? 'Keep the fire alive!' : 'Save today to start!',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.calculate_rounded,
                iconColor: AppTheme.softCoral,
                label: 'AVG ENVELOPE',
                value:
                    '${goal.currencySymbol}${goal.allowCents ? avgSeg.toStringAsFixed(2) : avgSeg.toStringAsFixed(0)}',
                subText: 'Average tile cost',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.arrow_downward_rounded,
                iconColor: AppTheme.warmPeach,
                label: 'SMALLEST TILE',
                value:
                    '${goal.currencySymbol}${goal.allowCents ? minSeg.toStringAsFixed(2) : minSeg.toStringAsFixed(0)}',
                subText: 'Easiest deposit',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.arrow_upward_rounded,
                iconColor: AppTheme.softCoral,
                label: 'LARGEST TILE',
                value:
                    '${goal.currencySymbol}${goal.allowCents ? maxSeg.toStringAsFixed(2) : maxSeg.toStringAsFixed(0)}',
                subText: 'Biggest challenge',
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Timeline Activity History Section Header
        Text(
          'SAVINGS ACTIVITY HISTORY',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: isDark ? AppTheme.textSecondary : AppTheme.mutedSlate,
          ),
        ),
        const SizedBox(height: 10),

        if (completedSegments.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.mutedSlate.withValues(alpha: 0.92)
                    : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 38,
                    color: isDark
                        ? AppTheme.textSecondary.withValues(alpha: 0.4)
                        : AppTheme.mutedSlate.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No savings activity yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap any envelope tile or draw a mystery envelope to log your first savings!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.mutedSlate,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedSegments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = completedSegments[index];
              final dateStr = item.completedAt != null
                  ? DateFormat.yMMMd().add_jm().format(item.completedAt!)
                  : 'Recent';
              final amt = goal.allowCents
                  ? item.amount.toStringAsFixed(2)
                  : item.amount.toStringAsFixed(0);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.mutedSlate.withValues(alpha: 0.92)
                      : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.warmPeach.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.warmPeach.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.warmPeach,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Envelope #${item.index}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.textSecondary
                                  : AppTheme.mutedSlate,
                            ),
                          ),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Note: ${item.note}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.softCoral,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${goal.currencySymbol}$amt',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.warmPeach,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subText;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.mutedSlate.withValues(alpha: 0.92)
            : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.textSecondary : AppTheme.mutedSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppTheme.textSecondary
                  : AppTheme.mutedSlate,
            ),
          ),
        ],
      ),
    );
  }
}
