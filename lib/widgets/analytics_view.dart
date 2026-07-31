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
            const SizedBox(width: 12),
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

        const SizedBox(height: 12),

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
            const SizedBox(width: 12),
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

        const SizedBox(height: 24),

        // Timeline Activity History Section Header
        Text(
          'SAVINGS ACTIVITY HISTORY',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: isDark ? AppTheme.textSecondary : Colors.black54,
          ),
        ),
        const SizedBox(height: 10),

        if (completedSegments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.mutedSlate : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 40,
                  color: isDark ? AppTheme.textSecondary.withValues(alpha: 0.4) : Colors.black26,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No savings activity yet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap any envelope tile or draw a mystery envelope to log your first savings!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondary : Colors.black54,
                  ),
                ),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.mutedSlate : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warmPeach.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.warmPeach,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Envelope #${item.index}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppTheme.textSecondary : Colors.black54,
                            ),
                          ),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Note: ${item.note}',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.mutedSlate : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textSecondary : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.textPrimary : const Color(0xFF231E3D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

