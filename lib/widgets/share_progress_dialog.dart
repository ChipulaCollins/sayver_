import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class ShareProgressDialog extends StatelessWidget {
  final SavingsGoal goal;
  final int streakDays;

  const ShareProgressDialog({
    super.key,
    required this.goal,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentInt = (goal.progressPercentage * 100).toInt();

    final savedStr = goal.allowCents
        ? goal.savedAmount.toStringAsFixed(2)
        : goal.savedAmount.toStringAsFixed(0);
    final targetStr = goal.allowCents
        ? goal.targetAmount.toStringAsFixed(2)
        : goal.targetAmount.toStringAsFixed(0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: goal.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        color: goal.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Share Challenge Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Share Card Graphic Preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF1F5F9),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: goal.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: goal.primaryColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // App Brand Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.savings_rounded,
                              size: 18, color: goal.primaryColor),
                          const SizedBox(width: 6),
                          const Text(
                            'Sayver',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: goal.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$percentInt% Completed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: goal.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Goal Title & Amount
                  Text(
                    goal.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Saved ${goal.currencySymbol} $savedStr of ${goal.currencySymbol} $targetStr',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: goal.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Streak & Milestones Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                size: 14, color: AppTheme.accentGold),
                            const SizedBox(width: 4),
                            Text(
                              '$streakDays Day Streak',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${goal.completedCount}/${goal.segmentCount} Tiles Saved',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Mini Tile Grid Visualizer Preview
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: goal.segments.take(24).map((s) {
                      return Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: s.isCompleted
                              ? goal.primaryColor
                              : isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Challenge started ${DateFormat.yMMMd().format(goal.createdAt)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: goal.primaryColor,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text(
                'Copy Progress Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final text =
                    '🎯 Sayver Savings Challenge: I\'ve saved ${goal.currencySymbol} $savedStr of ${goal.currencySymbol} $targetStr ($percentInt%) for "${goal.title}"! 🔥 $streakDays day streak!';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied to clipboard: "$text"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
