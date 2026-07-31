import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class GoalHeaderCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onSurprisePick;
  final VoidCallback onAutoDeposit;
  final VoidCallback onShuffleSegments;
  final VoidCallback onEditGoal;

  const GoalHeaderCard({
    super.key,
    required this.goal,
    required this.onSurprisePick,
    required this.onAutoDeposit,
    required this.onShuffleSegments,
    required this.onEditGoal,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'shield':
        return Icons.security_rounded;
      case 'mail':
        return Icons.mark_email_unread_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'tech':
        return Icons.laptop_mac_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'savings':
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

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

    final pace = goal.estimatedDailyPace;
    final paceStr = goal.allowCents ? pace.toStringAsFixed(2) : pace.toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.mutedSlate,
                  AppTheme.darkNavy,
                ]
              : [
                  Colors.white,
                  const Color(0xFFF4EFF8),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmPeach.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row: Category Badge & Title & Options Menu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warmPeach.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.warmPeach.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  _getCategoryIcon(goal.iconName),
                  color: AppTheme.warmPeach,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: isDark ? AppTheme.textPrimary : const Color(0xFF231E3D),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.softCoral.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            goal.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.softCoral,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${goal.completedCount}/${goal.segmentCount} Envelopes Done',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textSecondary : Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppTheme.textSecondary : Colors.black54,
                ),
                onPressed: onEditGoal,
                tooltip: 'Goal Settings',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main Amount Counter & Warm Peach Percentage Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${goal.currencySymbol} $savedStr ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: AppTheme.warmPeach,
                            ),
                          ),
                          TextSpan(
                            text: '/ ${goal.currencySymbol} $targetStr',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.textSecondary : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Percentage Badge with Soft Coral Glow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warmPeach, AppTheme.softCoral],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.softCoral.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Modern Gradient Progress Bar (Warm Peach -> Soft Coral)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  color: isDark ? AppTheme.darkNavy.withValues(alpha: 0.6) : AppTheme.lightBorder,
                ),
                FractionallySizedBox(
                  widthFactor: goal.progressPercentage,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.warmPeach,
                          AppTheme.softCoral,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Sub-Metrics Bar: Remaining balance & Daily recommended pace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.savings_outlined, size: 14, color: AppTheme.softCoral),
                  const SizedBox(width: 4),
                  Text(
                    'Remaining: ${goal.currencySymbol} ${(goal.remainingAmount).toStringAsFixed(goal.allowCents ? 2 : 0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textSecondary : Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 14, color: AppTheme.warmPeach),
                  const SizedBox(width: 4),
                  Text(
                    'Pace: ${goal.currencySymbol} $paceStr/day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warmPeach,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Action Toolbar: Mystery Draw, Deposit Budget, Shuffle
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.casino_rounded,
                  label: 'Mystery Draw',
                  color: AppTheme.warmPeach,
                  onTap: onSurprisePick,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Auto Deposit',
                  color: AppTheme.softCoral,
                  onTap: onAutoDeposit,
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.shuffle_rounded,
                label: 'Shuffle',
                color: AppTheme.warmPeach,
                isIconButton: true,
                onTap: onShuffleSegments,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isIconButton;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isIconButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 11,
            horizontal: isIconButton ? 12 : 12,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.16 : 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              if (!isIconButton) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

