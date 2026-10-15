import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final accentColor = AppTheme.warmPeach;
    final secondaryAccent = AppTheme.softCoral;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.mutedSlate.withValues(alpha: 0.92)
                      : AppTheme.lightSurface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.share_rounded,
                                    color: accentColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'Share Challenge Progress',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: -0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Share Card Graphic Preview
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    AppTheme.darkNavy.withValues(alpha: 0.95),
                                    AppTheme.elevatedCard.withValues(alpha: 0.95),
                                  ]
                                : [
                                    Colors.white,
                                    AppTheme.lightCard,
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            // App Brand Logo & Percent Badge (Overflow-safe)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.savings_rounded,
                                        size: 18,
                                        color: accentColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Sayver',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            letterSpacing: -0.3,
                                            color: isDark
                                                ? AppTheme.textPrimary
                                                : AppTheme.textDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '$percentInt% Completed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: accentColor,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saved ${goal.currencySymbol} $savedStr of ${goal.currencySymbol} $targetStr',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Streak & Milestones Row
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warmPeach.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppTheme.warmPeach.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 14,
                                        color: AppTheme.warmPeach,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$streakDays Day Streak',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.warmPeach,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: secondaryAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: secondaryAccent.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '${goal.completedCount}/${goal.segmentCount} Tiles Saved',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: secondaryAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

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
                                        ? accentColor
                                        : (isDark
                                            ? AppTheme.elevatedCard
                                            : AppTheme.lightBorder),
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: s.isCompleted
                                          ? accentColor
                                          : (isDark
                                              ? AppTheme.borderSlate
                                              : AppTheme.lightBorder),
                                      width: 0.5,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 12),
                            Text(
                              'Challenge started ${DateFormat.yMMMd().format(goal.createdAt)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.textSecondary.withValues(alpha: 0.6)
                                    : AppTheme.mutedSlate.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Action Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.warmPeach : AppTheme.darkNavy,
                          foregroundColor: isDark ? AppTheme.textDark : AppTheme.textPrimary,
                          minimumSize: const Size(double.infinity, 46),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDark ? AppTheme.warmPeach : AppTheme.borderSlate,
                              width: 0.8,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text(
                          'Copy Progress Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () async {
                          final text =
                              '🎯 Sayver Savings Challenge: I\'ve saved ${goal.currencySymbol} $savedStr of ${goal.currencySymbol} $targetStr ($percentInt%) for "${goal.title}"! 🔥 $streakDays day streak!';
                          await Clipboard.setData(ClipboardData(text: text));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied to clipboard: "$text"'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
