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
    {'name': 'emerald', 'color': const Color(0xFF10B981), 'label': 'Emerald'},
    {'name': 'gold', 'color': const Color(0xFFF59E0B), 'label': 'Gold'},
    {'name': 'cyan', 'color': const Color(0xFF06B6D4), 'label': 'Cyan'},
    {'name': 'rose', 'color': const Color(0xFFF43F5E), 'label': 'Rose'},
    {'name': 'purple', 'color': const Color(0xFF8B5CF6), 'label': 'Purple'},
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
        return const Color(0xFF06B6D4);
      case 'rose':
        return const Color(0xFFF43F5E);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'emerald':
      default:
        return const Color(0xFF10B981);
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.all(22),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _activeAccentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_task_rounded,
                          color: _activeAccentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'New Savings Goal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Live Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _activeAccentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _activeAccentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_currencySymbol ${_targetAmount.toStringAsFixed(_allowCents ? 2 : 0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _activeAccentColor,
                          ),
                        ),
                        Text(
                          '$_segmentCount Random Envelopes',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '~$_currencySymbol $avgStr avg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Tab Selector
              TabBar(
                controller: _tabController,
                indicatorColor: _activeAccentColor,
                labelColor: _activeAccentColor,
                unselectedLabelColor:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: '1. Essentials'),
                  Tab(text: '2. Style & Custom'),
                ],
              ),

              const SizedBox(height: 14),

              // Tab Content Area
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: ESSENTIALS
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GOAL NAME',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Emergency Fund, Laptop',
                              prefixIcon: Icon(Icons.edit_outlined, size: 18),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a goal name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TARGET AMOUNT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.5),
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
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CURRENCY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _currencySymbol,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 14),
                                      ),
                                      items: _currencies.map((symbol) {
                                        return DropdownMenuItem(
                                          value: symbol,
                                          child: Text(
                                            symbol,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
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
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Text(
                            'NUMBER OF ENVELOPES',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [10, 20, 25, 50, 100].map((count) {
                              final selected = _segmentCount == count;
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: ChoiceChip(
                                    label: Text('$count'),
                                    selected: selected,
                                    selectedColor: _activeAccentColor,
                                    labelStyle: TextStyle(
                                      color: selected
                                          ? Colors.black
                                          : theme.textTheme.bodyMedium?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (sel) {
                                      if (sel) {
                                        setState(() {
                                          _segmentCount = count;
                                          _generatePreview();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // TAB 2: STYLE & CUSTOMIZATION
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCENT COLOR THEME',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
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
                                            alpha: selected ? 0.3 : 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selected
                                              ? color
                                              : Colors.transparent,
                                          width: selected ? 2 : 1,
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
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
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
                                                .withValues(alpha: 0.15)
                                            : (isDark
                                                ? AppTheme.darkCard
                                                : AppTheme.lightCard),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected
                                              ? _activeAccentColor
                                              : (isDark
                                                  ? AppTheme.darkBorder
                                                  : AppTheme.lightBorder),
                                        ),
                                      ),
                                      child: Text(
                                        type.label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: selected
                                              ? _activeAccentColor
                                              : theme
                                                  .textTheme.bodyMedium?.color,
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
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
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
                                                ? AppTheme.darkCard
                                                : AppTheme.lightCard),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected
                                              ? _activeAccentColor
                                              : (isDark
                                                  ? AppTheme.darkBorder
                                                  : AppTheme.lightBorder),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            opt['icon'] as IconData,
                                            size: 14,
                                            color: selected
                                                ? Colors.black
                                                : theme.textTheme.bodyMedium
                                                    ?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            opt['label'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: selected
                                                  ? Colors.black
                                                  : theme.textTheme.bodyMedium
                                                      ?.color,
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
                        foregroundColor: Colors.black,
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
    );
  }
}
