import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../services/segment_generator.dart';
import '../theme/app_theme.dart';

class CreateGoalDialog extends StatefulWidget {
  final Function(SavingsGoal) onCreateGoal;

  const CreateGoalDialog({
    super.key,
    required this.onCreateGoal,
  });

  @override
  State<CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<CreateGoalDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'My Savings Goal');
  final _amountController = TextEditingController(text: '1000');

  late TabController _tabController;

  double _targetAmount = 1000.0;
  int _segmentCount = 25;
  DistributionType _distributionType = DistributionType.random;
  String _currencySymbol = 'K';
  bool _allowCents = false;
  String _iconName = 'savings';
  String _category = 'General';
  String _colorTheme = 'emerald';
  final List<String> _currencies = ['K', 'ZMW', 'MWK', '\$', '€', '£', 'R', '¥', '₹'];

  final List<Map<String, dynamic>> _themeOptions = [
    {'name': 'emerald', 'color': AppTheme.warmPeach, 'label': 'Emerald'},
    {'name': 'gold', 'color': const Color(0xFFF59E0B), 'label': 'Gold'},
    {'name': 'cyan', 'color': AppTheme.softCoral, 'label': 'Cyan'},
    {'name': 'rose', 'color': const Color(0xFFF43F5E), 'label': 'Rose'},
    {'name': 'purple', 'color': AppTheme.accentPurple, 'label': 'Purple'},
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'savings', 'icon': Icons.account_balance_wallet_rounded, 'label': 'Savings'},
    {'name': 'shield', 'icon': Icons.security_rounded, 'label': 'Emergency'},
    {'name': 'flight', 'icon': Icons.flight_takeoff_rounded, 'label': 'Travel'},
    {'name': 'tech', 'icon': Icons.laptop_mac_rounded, 'label': 'Gadgets'},
    {'name': 'car', 'icon': Icons.directions_car_rounded, 'label': 'Vehicle'},
    {'name': 'home', 'icon': Icons.home_rounded, 'label': 'Home'},
    {'name': 'mail', 'icon': Icons.mark_email_unread_rounded, 'label': 'Challenge'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generatePreview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _generatePreview() {
    final parsed = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 1000.0;
    _targetAmount = parsed > 0 ? parsed : 1000.0;
    setState(() {});
  }

  Color get _activeAccentColor {
    switch (_colorTheme) {
      case 'gold':
        return const Color(0xFFF59E0B);
      case 'cyan':
        return AppTheme.softCoral;
      case 'rose':
        return const Color(0xFFF43F5E);
      case 'purple':
        return AppTheme.accentPurple;
      case 'emerald':
      default:
        return AppTheme.warmPeach;
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final goalId = 'goal_${now.millisecondsSinceEpoch}';

      final finalSegments = SegmentGenerator.generateSegments(
        goalId: goalId,
        targetAmount: _targetAmount,
        count: _segmentCount,
        distributionType: _distributionType,
        allowCents: _allowCents,
      );

      final newGoal = SavingsGoal(
        id: goalId,
        title: _titleController.text.trim(),
        targetAmount: _targetAmount,
        currencySymbol: _currencySymbol,
        segmentCount: _segmentCount,
        distributionType: _distributionType,
        segments: finalSegments,
        createdAt: now,
        category: _category,
        iconName: _iconName,
        allowCents: _allowCents,
        colorTheme: _colorTheme,
      );

      widget.onCreateGoal(newGoal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avgAmount = _targetAmount / (_segmentCount > 0 ? _segmentCount : 1);
    final avgStr = _allowCents
        ? avgAmount.toStringAsFixed(2)
        : avgAmount.toStringAsFixed(0);

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = (screenHeight - 32).clamp(380.0, 720.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
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
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: _activeAccentColor.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _activeAccentColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_task_rounded,
                                  color: _activeAccentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'New Savings Goal',
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

                    const SizedBox(height: 12),

                    // Live Summary Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeAccentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _activeAccentColor.withValues(alpha: 0.28),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_currencySymbol ${_targetAmount.toStringAsFixed(_allowCents ? 2 : 0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: _activeAccentColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$_segmentCount Random Envelopes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.textSecondary
                                        : AppTheme.mutedSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkNavy.withValues(alpha: 0.8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.borderSlate
                                    : AppTheme.lightBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '~$_currencySymbol $avgStr avg',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tab Selector
                    TabBar(
                      controller: _tabController,
                      indicatorColor: _activeAccentColor,
                      labelColor: _activeAccentColor,
                      unselectedLabelColor: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.mutedSlate,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      dividerColor: isDark
                          ? AppTheme.borderSlate.withValues(alpha: 0.5)
                          : AppTheme.lightBorder,
                      tabs: const [
                        Tab(text: '1. Essentials'),
                        Tab(text: '2. Style & Custom'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tab Content Area
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // TAB 1: ESSENTIALS
                          SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GOAL NAME',
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
                                TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Emergency Fund, Laptop',
                                    prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                                    fillColor: isDark
                                        ? AppTheme.darkNavy.withValues(alpha: 0.6)
                                        : AppTheme.lightCard,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a goal name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isCompact = constraints.maxWidth < 260;
                                    final amountField = Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TARGET AMOUNT',
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
                                        TextFormField(
                                          controller: _amountController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            prefixText: '$_currencySymbol ',
                                            prefixStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            fillColor: isDark
                                                ? AppTheme.darkNavy.withValues(alpha: 0.6)
                                                : AppTheme.lightCard,
                                          ),
                                          onChanged: (_) => _generatePreview(),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Enter amount';
                                            }
                                            final val = double.tryParse(
                                                value.replaceAll(',', '.'));
                                            if (val == null || val <= 0) {
                                              return 'Enter valid amount > 0';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    );

                                    final currencyField = Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CURRENCY',
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
                                        DropdownButtonFormField<String>(
                                          initialValue: _currencySymbol,
                                          isDense: true,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 14),
                                            fillColor: isDark
                                                ? AppTheme.darkNavy.withValues(alpha: 0.6)
                                                : AppTheme.lightCard,
                                          ),
                                          items: _currencies.map((symbol) {
                                            return DropdownMenuItem(
                                              value: symbol,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  symbol,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _currencySymbol = val;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    );

                                    if (isCompact) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          amountField,
                                          const SizedBox(height: 14),
                                          currencyField,
                                        ],
                                      );
                                    }

                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: amountField,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 2,
                                          child: currencyField,
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  'NUMBER OF ENVELOPES',
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

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [10, 20, 25, 50, 100].map((count) {
                                    final selected = _segmentCount == count;
                                    return ChoiceChip(
                                      label: Text('$count'),
                                      selected: selected,
                                      selectedColor: _activeAccentColor,
                                      labelStyle: TextStyle(
                                        color: selected
                                            ? AppTheme.textDark
                                            : (isDark ? AppTheme.textPrimary : AppTheme.textDark),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      side: BorderSide(
                                        color: selected
                                            ? _activeAccentColor
                                            : (isDark ? AppTheme.borderSlate : AppTheme.lightBorder),
                                        width: 0.8,
                                      ),
                                      onSelected: (sel) {
                                        if (sel) {
                                          setState(() {
                                            _segmentCount = count;
                                            _generatePreview();
                                          });
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          // TAB 2: STYLE & CUSTOMIZATION
                          SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ACCENT COLOR THEME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.textSecondary
                                        : AppTheme.mutedSlate,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: _themeOptions.map((opt) {
                                    final name = opt['name'] as String;
                                    final color = opt['color'] as Color;
                                    final selected = _colorTheme == name;
                                    return Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 3),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _colorTheme = name;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                  alpha: selected ? 0.35 : 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: selected
                                                    ? color
                                                    : (isDark ? AppTheme.borderSlate : AppTheme.lightBorder),
                                                width: selected ? 1.6 : 0.8,
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                selected
                                                    ? Icons.check_rounded
                                                    : Icons.circle,
                                                size: 14,
                                                color: color,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  'DISTRIBUTION PATTERN',
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

                                Row(
                                  children: DistributionType.values.map((type) {
                                    final selected = _distributionType == type;
                                    return Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 2),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _distributionType = type;
                                              _generatePreview();
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? _activeAccentColor
                                                      .withValues(alpha: 0.2)
                                                  : (isDark
                                                      ? AppTheme.darkNavy.withValues(alpha: 0.6)
                                                      : AppTheme.lightCard),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: selected
                                                    ? _activeAccentColor
                                                    : (isDark
                                                        ? AppTheme.borderSlate
                                                        : AppTheme.lightBorder),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              type.label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: selected
                                                    ? (isDark ? AppTheme.textPrimary : AppTheme.textDark)
                                                    : (isDark ? AppTheme.textSecondary : AppTheme.mutedSlate),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  'CATEGORY ICON',
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
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _iconOptions.map((opt) {
                                      final selected = _iconName == opt['name'];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _iconName = opt['name'] as String;
                                              _category = opt['label'] as String;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? _activeAccentColor
                                                  : (isDark
                                                      ? AppTheme.darkNavy.withValues(alpha: 0.6)
                                                      : AppTheme.lightCard),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: selected
                                                    ? _activeAccentColor
                                                    : (isDark
                                                        ? AppTheme.borderSlate
                                                        : AppTheme.lightBorder),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  opt['icon'] as IconData,
                                                  size: 14,
                                                  color: selected
                                                      ? AppTheme.textDark
                                                      : (isDark ? AppTheme.textPrimary : AppTheme.textDark),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  opt['label'] as String,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: selected
                                                        ? AppTheme.textDark
                                                        : (isDark ? AppTheme.textPrimary : AppTheme.textDark),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SwitchListTile(
                                  value: _allowCents,
                                  activeTrackColor: _activeAccentColor,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Allow Decimals / Cents',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Generate exact cents (K 14.50) vs whole Kwacha (K 14)',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _allowCents = val;
                                      _generatePreview();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Bottom Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppTheme.textSecondary : AppTheme.mutedSlate,
                              side: BorderSide(
                                color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                                width: 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _activeAccentColor,
                              foregroundColor: AppTheme.textDark,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'Create Goal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
}
