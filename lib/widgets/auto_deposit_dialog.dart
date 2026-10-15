import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class AutoDepositDialog extends StatefulWidget {
  final SavingsGoal goal;
  final Function(List<SavingsSegment>) onDepositSegments;

  const AutoDepositDialog({
    super.key,
    required this.goal,
    required this.onDepositSegments,
  });

  @override
  State<AutoDepositDialog> createState() => _AutoDepositDialogState();
}

class _AutoDepositDialogState extends State<AutoDepositDialog> {
  final _amountController = TextEditingController(text: '50');
  List<SavingsSegment> _matchedSegments = [];
  double _totalMatched = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateMatches();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateMatches() {
    final deposit = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    if (deposit <= 0) {
      setState(() {
        _matchedSegments = [];
        _totalMatched = 0.0;
      });
      return;
    }

    final available = widget.goal.segments.where((s) => !s.isCompleted).toList();
    available.sort((a, b) => b.amount.compareTo(a.amount));

    List<SavingsSegment> selected = [];
    double currentSum = 0.0;

    for (var seg in available) {
      if (currentSum + seg.amount <= deposit + 0.01) {
        selected.add(seg);
        currentSum += seg.amount;
      }
    }

    if (selected.isEmpty && available.isNotEmpty) {
      var closest = available.last;
      selected.add(closest);
      currentSum = closest.amount;
    }

    setState(() {
      _matchedSegments = selected;
      _totalMatched = currentSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = AppTheme.warmPeach;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = (screenHeight - 32).clamp(360.0, 680.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: maxHeight),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog Title Row
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
                                  Icons.add_card_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Quick Deposit',
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

                    const SizedBox(height: 14),
                    Text(
                      'Enter the amount of money you want to put into savings today. Sayver will automatically pick the best matching segment(s)!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.mutedSlate,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Deposit Input Field
                    Text(
                      'DEPOSIT AMOUNT TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.mutedSlate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                      ),
                      decoration: InputDecoration(
                        prefixText: '${widget.goal.currencySymbol} ',
                        prefixStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                        fillColor: isDark
                            ? AppTheme.darkNavy.withValues(alpha: 0.6)
                            : AppTheme.lightCard,
                      ),
                      onChanged: (_) => _calculateMatches(),
                    ),

                    const SizedBox(height: 18),

                    // Matched Segments Preview Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkNavy.withValues(alpha: 0.6)
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Matched Envelopes (${_matchedSegments.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark
                                        ? AppTheme.textPrimary
                                        : AppTheme.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total: ${widget.goal.currencySymbol}${widget.goal.allowCents ? _totalMatched.toStringAsFixed(2) : _totalMatched.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_matchedSegments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'No matching uncompleted envelopes found.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppTheme.textSecondary.withValues(alpha: 0.7)
                                      : AppTheme.mutedSlate.withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 140),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _matchedSegments.map((seg) {
                                    final amt = widget.goal.allowCents
                                        ? seg.amount.toStringAsFixed(2)
                                        : seg.amount.toStringAsFixed(0);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: accentColor.withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '#${seg.index}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.goal.currencySymbol}$amt',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Submit button
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
                      onPressed: _matchedSegments.isEmpty
                          ? null
                          : () {
                              widget.onDepositSegments(_matchedSegments);
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        'Complete ${_matchedSegments.length} Envelopes (${widget.goal.currencySymbol}${widget.goal.allowCents ? _totalMatched.toStringAsFixed(2) : _totalMatched.toStringAsFixed(0)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
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
}
