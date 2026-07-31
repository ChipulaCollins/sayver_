import 'dart:math';
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Today's Envelope",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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

            const SizedBox(height: 20),

            if (uncompleted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'All Envelopes Saved!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have completed all segments for ${widget.goal.title}. Outstanding job!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animated Envelope Card
                  GestureDetector(
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
                                  child: _buildRevealedCard(theme, isDark),
                                )
                              : _buildCoverCard(theme, isDark),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (_isFlipped)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              backgroundColor: AppTheme.warmPeach,
                              foregroundColor: AppTheme.textDark,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                        backgroundColor: AppTheme.warmPeach,
                        foregroundColor: AppTheme.textDark,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _revealEnvelope,
                      child: const Text(
                        'Tap to Open Envelope ✉️',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverCard(ThemeData theme, bool isDark) {
    return Container(
      width: 260,
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              size: 48,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Envelope #${_selectedSegment?.index}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedCard(ThemeData theme, bool isDark) {
    final amt = widget.goal.allowCents
        ? _selectedSegment?.amount.toStringAsFixed(2)
        : _selectedSegment?.amount.toStringAsFixed(0);

    return Container(
      width: 260,
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
          const SizedBox(height: 8),
          Text(
            '${widget.goal.currencySymbol}$amt',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Target for Today',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

