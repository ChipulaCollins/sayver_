import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class SegmentDetailDialog extends StatefulWidget {
  final SavingsSegment segment;
  final String currencySymbol;
  final bool allowCents;
  final Function(SavingsSegment updated) onSave;

  const SegmentDetailDialog({
    super.key,
    required this.segment,
    required this.currencySymbol,
    required this.allowCents,
    required this.onSave,
  });

  @override
  State<SegmentDetailDialog> createState() => _SegmentDetailDialogState();
}

class _SegmentDetailDialogState extends State<SegmentDetailDialog> {
  late bool _isCompleted;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.segment.isCompleted;
    _noteController = TextEditingController(text: widget.segment.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = widget.segment.copyWith(
      isCompleted: _isCompleted,
      completedAt: _isCompleted
          ? (widget.segment.completedAt ?? DateTime.now())
          : null,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final amtFormatted = widget.allowCents
        ? widget.segment.amount.toStringAsFixed(2)
        : widget.segment.amount.toStringAsFixed(0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: _isCompleted
                            ? AppTheme.primaryEmerald.withValues(alpha: 0.15)
                            : (isDark
                                ? AppTheme.darkCard
                                : AppTheme.lightCard),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.mark_email_unread_rounded,
                        color: _isCompleted
                            ? AppTheme.primaryEmerald
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Envelope #${widget.segment.index}',
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

            // Amount Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'SEGMENT VALUE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.currencySymbol}$amtFormatted',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: _isCompleted
                          ? AppTheme.primaryEmerald
                          : theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  if (_isCompleted && widget.segment.completedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Saved on ${DateFormat.yMMMd().format(widget.segment.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status toggle switch
            SwitchListTile(
              value: _isCompleted,
              activeTrackColor: AppTheme.primaryEmerald,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Mark as Saved',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _isCompleted
                    ? 'This envelope is counted towards your savings goal.'
                    : 'Check this when you put this money into your savings account/jar.',
                style: const TextStyle(fontSize: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _isCompleted = val;
                });
              },
            ),

            const SizedBox(height: 14),

            // Optional note field
            Text(
              'SAVINGS NOTE (OPTIONAL)',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'e.g., Saved from groceries, side hustle income',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
            ),

            const SizedBox(height: 24),

            // Action button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                'Save Changes',
                style: TextStyle(
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
