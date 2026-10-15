import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class EnvelopeTile extends StatefulWidget {
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
  State<EnvelopeTile> createState() => _EnvelopeTileState();
}

class _EnvelopeTileState extends State<EnvelopeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (mounted) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (mounted) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (mounted) {
      _controller.reverse();
    }
  }

  void _handleLongPress() {
    if (mounted) {
      _controller.reverse();
    }
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDone = widget.segment.isCompleted;

    final formattedAmount = widget.allowCents
        ? widget.segment.amount.toStringAsFixed(2)
        : widget.segment.amount.toStringAsFixed(0);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
          onLongPress: _handleLongPress,
          borderRadius: BorderRadius.circular(16),
          splashColor: (isDone ? AppTheme.textDark : AppTheme.warmPeach).withValues(alpha: 0.18),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isDone
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.warmPeach,
                        Color(0xFFE8B078),
                      ],
                    )
                  : null,
              color: isDone
                  ? null
                  : (isDark ? AppTheme.elevatedCard : AppTheme.lightCard),
              boxShadow: isDone
                  ? [
                      BoxShadow(
                        color: AppTheme.warmPeach.withValues(alpha: 0.38),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
              border: Border.all(
                color: isDone
                    ? AppTheme.warmPeach
                    : (isDark
                        ? AppTheme.borderSlate.withValues(alpha: 0.7)
                        : AppTheme.lightBorder),
                width: isDone ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Minimalist Index Pill + Micro Checkmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppTheme.textDark.withValues(alpha: 0.12)
                              : (isDark
                                  ? AppTheme.darkNavy.withValues(alpha: 0.55)
                                  : Colors.black.withValues(alpha: 0.06)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${widget.segment.index}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDone
                                ? AppTheme.textDark.withValues(alpha: 0.88)
                                : (isDark ? AppTheme.textSecondary : AppTheme.textDark.withValues(alpha: 0.7)),
                          ),
                        ),
                      ),
                      if (isDone)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: AppTheme.textDark,
                        )
                      else if (widget.segment.note != null && widget.segment.note!.isNotEmpty)
                        const Icon(
                          Icons.note_rounded,
                          size: 13,
                          color: AppTheme.warmPeach,
                        )
                      else
                        Icon(
                          Icons.circle_outlined,
                          size: 12,
                          color: isDark ? AppTheme.borderSlate : Colors.black26,
                        ),
                    ],
                  ),

                  // Center Hero: Crisp Clean Amount
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${widget.currencySymbol} $formattedAmount',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: isDone
                            ? AppTheme.textDark
                            : (isDark ? AppTheme.textPrimary : AppTheme.textDark),
                      ),
                    ),
                  ),

                  // Bottom Subtext: Saved indicator or note
                  if (isDone)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.textDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'SAVED',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                          color: AppTheme.warmPeach,
                        ),
                      ),
                    )
                  else if (widget.segment.note != null && widget.segment.note!.isNotEmpty)
                    Text(
                      widget.segment.note!,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.warmPeach : AppTheme.darkNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
