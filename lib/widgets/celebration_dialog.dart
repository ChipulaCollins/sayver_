import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class CelebrationDialog extends StatelessWidget {
  final SavingsGoal goal;

  const CelebrationDialog({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amtStr = goal.allowCents
        ? goal.targetAmount.toStringAsFixed(2)
        : goal.targetAmount.toStringAsFixed(0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎉 GOAL COMPLETED! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You successfully saved ${goal.currencySymbol}$amtStr for "${goal.title}"!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _VictoryMetric(
                    label: 'TOTAL SAVED',
                    value: '${goal.currencySymbol}$amtStr',
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                  ),
                  _VictoryMetric(
                    label: 'ENVELOPES',
                    value: '${goal.segmentCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VictoryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _VictoryMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppTheme.primaryEmerald,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
