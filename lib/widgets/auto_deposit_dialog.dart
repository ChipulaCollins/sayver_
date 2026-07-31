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

  void _calculateMatches() {
    final deposit = double.tryParse(_amountController.text) ?? 0.0;
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_card_rounded,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Deposit',
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

            const SizedBox(height: 16),
            Text(
              'Enter the amount of money you want to put into savings today. Sayver will automatically pick the best matching segment(s)!',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 20),

            // Deposit Input Field
            Text(
              'DEPOSIT AMOUNT TODAY',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText: '${widget.goal.currencySymbol} ',
                prefixStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onChanged: (_) => _calculateMatches(),
            ),

            const SizedBox(height: 20),

            // Matched Segments Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Matched Envelopes (${_matchedSegments.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Total: ${widget.goal.currencySymbol}${widget.goal.allowCents ? _totalMatched.toStringAsFixed(2) : _totalMatched.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_matchedSegments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No matching uncompleted envelopes found.',
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _matchedSegments.map((seg) {
                        final amt = widget.goal.allowCents
                            ? seg.amount.toStringAsFixed(2)
                            : seg.amount.toStringAsFixed(0);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primaryEmerald.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#${seg.index}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryEmerald,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.goal.currencySymbol}$amt',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
