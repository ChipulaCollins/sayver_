import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class SurpriseEnvelopeDialog extends StatefulWidget {
  final SavingsGoal goal;
  final Function(SavingsSegment) onCompleteSegment;

  const SurpriseEnvelopeDialog({
    super.key,
    required this.goal,
    required this.onCompleteSegment,
  });

  @override
  State<SurpriseEnvelopeDialog> createState() => _SurpriseEnvelopeDialogState();
}

class _SurpriseEnvelopeDialogState extends State<SurpriseEnvelopeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  SavingsSegment? _selectedSegment;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _pickRandomSegment();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickRandomSegment() {
    final uncompleted = widget.goal.segments.where((s) => !s.isCompleted).toList();
    if (uncompleted.isEmpty) {
      _selectedSegment = null;
      return;
    }

    final rand = Random();
    setState(() {
      _selectedSegment = uncompleted[rand.nextInt(uncompleted.length)];
      _isFlipped = false;
    });
    _controller.reset();
  }

  void _revealEnvelope() {
    if (!_isFlipped) {
      setState(() {
        _isFlipped = true;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uncompleted = widget.goal.segments.where((s) => !s.isCompleted).toList();
    final accentColor = AppTheme.warmPeach;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = (screenHeight - 32).clamp(360.0, 680.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.mutedSlate.withValues(alpha: 0.94)
                    : AppTheme.lightSurface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                                  Icons.casino_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  "Today's Envelope",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    letterSpacing: -0.3,
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

                    const SizedBox(height: 18),

                    if (uncompleted.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                size: 56,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'All Envelopes Saved!',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have completed all segments for ${widget.goal.title}. Outstanding job!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.textSecondary
                                    : AppTheme.mutedSlate,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_selectedSegment != null)
                      Column(
                        children: [
                          Text(
                            _isFlipped
                                ? 'Here is your savings target for today!'
                                : 'Tap the envelope to reveal today\'s savings amount!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.textSecondary
                                  : AppTheme.mutedSlate,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Animated Envelope Card (Responsive width)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cardWidth = constraints.maxWidth.clamp(200.0, 260.0);
                              return GestureDetector(
                                onTap: _revealEnvelope,
                                child: AnimatedBuilder(
                                  animation: _flipAnimation,
                                  builder: (context, child) {
                                    final angle = _flipAnimation.value * pi;
                                    final isUnder = angle > (pi / 2);

                                    return Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(angle),
                                      alignment: Alignment.center,
                                      child: isUnder
                                          ? Transform(
                                              transform: Matrix4.identity()..rotateY(pi),
                                              alignment: Alignment.center,
                                              child: _buildRevealedCard(theme, isDark, cardWidth),
                                            )
                                          : _buildCoverCard(theme, isDark, cardWidth),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 22),

                          // Action buttons
                          if (_isFlipped)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark ? AppTheme.textSecondary : AppTheme.mutedSlate,
                                      side: BorderSide(
                                        color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                                        width: 0.8,
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Try Another'),
                                    onPressed: _pickRandomSegment,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: AppTheme.textDark,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                                    label: const Text(
                                      'Save Now!',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      widget.onCompleteSegment(_selectedSegment!);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: AppTheme.textDark,
                                minimumSize: const Size(double.infinity, 48),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _revealEnvelope,
                              child: const Text(
                                'Tap to Open Envelope ✉️',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverCard(ThemeData theme, bool isDark, double width) {
    final accentColor = AppTheme.warmPeach;
    return Container(
      width: width,
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkNavy : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Icon(
              Icons.mark_email_unread_rounded,
              size: 44,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Envelope #${_selectedSegment?.index}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedCard(ThemeData theme, bool isDark, double width) {
    final amt = widget.goal.allowCents
        ? _selectedSegment?.amount.toStringAsFixed(2)
        : _selectedSegment?.amount.toStringAsFixed(0);

    return Container(
      width: width,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warmPeach,
            AppTheme.softCoral,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.softCoral.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ENVELOPE #${_selectedSegment?.index}',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.goal.currencySymbol}$amt',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
            child: const Text(
              'Target for Today',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
