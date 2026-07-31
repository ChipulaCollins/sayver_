import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class EnvelopeTile extends StatelessWidget {
  final SavingsSegment segment;
  final String currencySymbol;
  final bool allowCents;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EnvelopeTile({
    super.key,
    required this.segment,
    required this.currencySymbol,
    required this.allowCents,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDone = segment.isCompleted;

    final formattedAmount = allowCents
        ? segment.amount.toStringAsFixed(2)
        : segment.amount.toStringAsFixed(0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.warmPeach.withValues(alpha: 0.3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isDone
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.warmPeach,
                      AppTheme.softCoral,
                    ],
                  )
                : null,
            color: isDone
                ? null
                : (isDark ? AppTheme.elevatedCard : AppTheme.lightCard),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: AppTheme.softCoral.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
            border: Border.all(
              color: isDone
                  ? AppTheme.warmPeach
                  : (isDark ? AppTheme.borderSlate : AppTheme.lightBorder),
              width: isDone ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Row (Index & Status Icon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${segment.index}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDone
                            ? AppTheme.textDark.withValues(alpha: 0.8)
                            : (isDark ? AppTheme.textSecondary : Colors.black45),
                      ),
                    ),
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.mark_email_unread_outlined,
                      size: 16,
                      color: isDone
                          ? AppTheme.textDark
                          : (isDark ? AppTheme.textSecondary.withValues(alpha: 0.6) : Colors.black38),
                    ),
                  ],
                ),

                const Spacer(),

                // Center Amount Display
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$currencySymbol $formattedAmount',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDone
                          ? AppTheme.textDark
                          : (isDark ? AppTheme.textPrimary : const Color(0xFF231E3D)),
                    ),
                  ),
                ),

                const Spacer(),

                // Footer Note Indicator or SAVED Status
                if (segment.note != null && segment.note!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sticky_note_2_rounded,
                        size: 10,
                        color: isDone ? AppTheme.textDark : AppTheme.warmPeach,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          segment.note!,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isDone ? AppTheme.textDark : AppTheme.warmPeach,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    isDone ? 'SAVED' : '',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isDone ? AppTheme.textDark : Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

