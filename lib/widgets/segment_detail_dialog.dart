import 'dart:ui';
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
    final accentColor = AppTheme.warmPeach;

    final amtFormatted = widget.allowCents
        ? widget.segment.amount.toStringAsFixed(2)
        : widget.segment.amount.toStringAsFixed(0);

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = (screenHeight - 32).clamp(360.0, 680.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: maxHeight),
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isCompleted
                                      ? accentColor.withValues(alpha: 0.18)
                                      : (isDark
                                          ? AppTheme.darkNavy.withValues(alpha: 0.6)
                                          : AppTheme.lightCard),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isCompleted
                                        ? accentColor.withValues(alpha: 0.35)
                                        : (isDark
                                            ? AppTheme.borderSlate
                                            : AppTheme.lightBorder),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  _isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.mark_email_unread_rounded,
                                  color: _isCompleted
                                      ? accentColor
                                      : (isDark
                                          ? AppTheme.textSecondary
                                          : AppTheme.mutedSlate),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Envelope #${widget.segment.index}',
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

                    // Amount Display Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                        children: [
                          Text(
                            'SEGMENT VALUE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.textSecondary
                                  : AppTheme.mutedSlate,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.currencySymbol}$amtFormatted',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: _isCompleted
                                  ? accentColor
                                  : (isDark
                                      ? AppTheme.textPrimary
                                      : AppTheme.textDark),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (_isCompleted && widget.segment.completedAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Saved on ${DateFormat.yMMMd().format(widget.segment.completedAt!)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.textSecondary.withValues(alpha: 0.7)
                                    : AppTheme.mutedSlate.withValues(alpha: 0.7),
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
                      activeTrackColor: accentColor,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Mark as Saved',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _isCompleted
                            ? 'This envelope is counted towards your savings goal.'
                            : 'Check this when you put this money into your savings account/jar.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.mutedSlate,
                        ),
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
                      controller: _noteController,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., Saved from groceries, side hustle income',
                        prefixIcon: const Icon(Icons.sticky_note_2_outlined, size: 18),
                        fillColor: isDark
                            ? AppTheme.darkNavy.withValues(alpha: 0.6)
                            : AppTheme.lightCard,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Action button
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
            ),
          ),
        ),
      ),
    );
  }
}
