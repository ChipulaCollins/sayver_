import 'package:flutter/material.dart';

import 'models/savings_goal.dart';
import 'services/segment_generator.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/analytics_view.dart';
import 'widgets/auto_deposit_dialog.dart';
import 'widgets/celebration_dialog.dart';
import 'widgets/confetti_overlay.dart';
import 'widgets/create_goal_dialog.dart';
import 'widgets/envelope_tile.dart';
import 'widgets/goal_header_card.dart';
import 'widgets/savings_jar_visualizer.dart';
import 'widgets/segment_detail_dialog.dart';
import 'widgets/share_progress_dialog.dart';
import 'widgets/surprise_envelope_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SayverApp());
}

class SayverApp extends StatefulWidget {
  const SayverApp({super.key});

  @override
  State<SayverApp> createState() => _SayverAppState();
}

class _SayverAppState extends State<SayverApp> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final dark = await StorageService.loadDarkMode();
    setState(() {
      _isDarkMode = dark;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    StorageService.saveDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

enum SegmentFilter { all, unsaved, saved }
enum SegmentSort { defaultIndex, amountAsc, amountDesc }

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavingsGoal> _goals = [];
  SavingsGoal? _activeGoal;
  bool _isLoading = true;
  bool _triggerConfetti = false;

  SegmentFilter _currentFilter = SegmentFilter.all;
  SegmentSort _currentSort = SegmentSort.defaultIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final loadedGoals = await StorageService.loadGoals();
    final activeId = await StorageService.loadActiveGoalId();

    SavingsGoal? selected;
    if (loadedGoals.isNotEmpty) {
      if (activeId != null) {
        selected = loadedGoals.firstWhere(
          (g) => g.id == activeId,
          orElse: () => loadedGoals.first,
        );
      } else {
        selected = loadedGoals.first;
      }
    }

    setState(() {
      _goals = loadedGoals;
      _activeGoal = selected;
      _isLoading = false;
    });
  }

  Future<void> _saveCurrentState() async {
    await StorageService.saveGoals(_goals);
    if (_activeGoal != null) {
      await StorageService.saveActiveGoalId(_activeGoal!.id);
    }
  }

  void _setActiveGoal(SavingsGoal goal) {
    setState(() {
      _activeGoal = goal;
    });
    StorageService.saveActiveGoalId(goal.id);
  }

  void _fireConfetti() {
    setState(() => _triggerConfetti = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _triggerConfetti = false);
    });
  }

  void _toggleSegmentCompletion(SavingsSegment segment) {
    if (_activeGoal == null) return;

    final wasDone = segment.isCompleted;
    final now = DateTime.now();

    final updatedSegments = _activeGoal!.segments.map((s) {
      if (s.id == segment.id) {
        return s.copyWith(
          isCompleted: !wasDone,
          completedAt: !wasDone ? now : null,
        );
      }
      return s;
    }).toList();

    final updatedGoal = SavingsGoal(
      id: _activeGoal!.id,
      title: _activeGoal!.title,
      targetAmount: _activeGoal!.targetAmount,
      currencySymbol: _activeGoal!.currencySymbol,
      segmentCount: _activeGoal!.segmentCount,
      distributionType: _activeGoal!.distributionType,
      segments: updatedSegments,
      createdAt: _activeGoal!.createdAt,
      targetDate: _activeGoal!.targetDate,
      category: _activeGoal!.category,
      iconName: _activeGoal!.iconName,
      allowCents: _activeGoal!.allowCents,
      colorTheme: _activeGoal!.colorTheme,
    );

    _updateGoalInList(updatedGoal);

    if (!wasDone) {
      _fireConfetti();
    }

    if (!wasDone && updatedGoal.isFullyCompleted) {
      _showCelebration(updatedGoal);
    }
  }

  void _updateGoalInList(SavingsGoal updatedGoal) {
    setState(() {
      _activeGoal = updatedGoal;
      final idx = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (idx != -1) {
        _goals[idx] = updatedGoal;
      }
    });
    _saveCurrentState();
  }

  void _showCelebration(SavingsGoal goal) {
    _fireConfetti();
    showDialog(
      context: context,
      builder: (context) => CelebrationDialog(goal: goal),
    );
  }

  void _openCreateGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGoalDialog(
        onCreateGoal: (newGoal) {
          setState(() {
            _goals.add(newGoal);
            _activeGoal = newGoal;
          });
          _saveCurrentState();
        },
      ),
    );
  }

  void _openShareDialog() {
    if (_activeGoal == null) return;
    showDialog(
      context: context,
      builder: (context) => ShareProgressDialog(
        goal: _activeGoal!,
        streakDays: 5,
      ),
    );
  }

  void _openSurprisePicker() {
    if (_activeGoal == null) return;
    showDialog(
      context: context,
      builder: (context) => SurpriseEnvelopeDialog(
        goal: _activeGoal!,
        onCompleteSegment: (segment) {
          _toggleSegmentCompletion(segment);
        },
      ),
    );
  }

  void _openAutoDeposit() {
    if (_activeGoal == null) return;
    showDialog(
      context: context,
      builder: (context) => AutoDepositDialog(
        goal: _activeGoal!,
        onDepositSegments: (matched) {
          final now = DateTime.now();
          final matchedIds = matched.map((m) => m.id).toSet();

          final updatedSegments = _activeGoal!.segments.map((s) {
            if (matchedIds.contains(s.id) && !s.isCompleted) {
              return s.copyWith(
                isCompleted: true,
                completedAt: now,
                note: 'Quick Auto-Deposit',
              );
            }
            return s;
          }).toList();

          final updatedGoal = SavingsGoal(
            id: _activeGoal!.id,
            title: _activeGoal!.title,
            targetAmount: _activeGoal!.targetAmount,
            currencySymbol: _activeGoal!.currencySymbol,
            segmentCount: _activeGoal!.segmentCount,
            distributionType: _activeGoal!.distributionType,
            segments: updatedSegments,
            createdAt: _activeGoal!.createdAt,
            targetDate: _activeGoal!.targetDate,
            category: _activeGoal!.category,
            iconName: _activeGoal!.iconName,
            allowCents: _activeGoal!.allowCents,
            colorTheme: _activeGoal!.colorTheme,
          );

          _updateGoalInList(updatedGoal);
          _fireConfetti();

          if (updatedGoal.isFullyCompleted) {
            _showCelebration(updatedGoal);
          }
        },
      ),
    );
  }

  void _shuffleCurrentGoalSegments() {
    if (_activeGoal == null) return;

    final newSegments = SegmentGenerator.generateSegments(
      goalId: _activeGoal!.id,
      targetAmount: _activeGoal!.targetAmount,
      count: _activeGoal!.segmentCount,
      distributionType: _activeGoal!.distributionType,
      allowCents: _activeGoal!.allowCents,
    );

    final updatedGoal = SavingsGoal(
      id: _activeGoal!.id,
      title: _activeGoal!.title,
      targetAmount: _activeGoal!.targetAmount,
      currencySymbol: _activeGoal!.currencySymbol,
      segmentCount: _activeGoal!.segmentCount,
      distributionType: _activeGoal!.distributionType,
      segments: newSegments,
      createdAt: _activeGoal!.createdAt,
      targetDate: _activeGoal!.targetDate,
      category: _activeGoal!.category,
      iconName: _activeGoal!.iconName,
      allowCents: _activeGoal!.allowCents,
      colorTheme: _activeGoal!.colorTheme,
    );

    _updateGoalInList(updatedGoal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Segments reshuffled with exact total sum preserved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openGoalSettings() {
    if (_activeGoal == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _activeGoal!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.share_rounded, color: _activeGoal!.primaryColor),
                  title: const Text('Share Progress Card'),
                  subtitle: const Text('Generate social media challenge summary'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openShareDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded, color: AppTheme.accentCyan),
                  title: const Text('Reset Goal Progress'),
                  subtitle: const Text('Uncheck all saved envelopes for this goal'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _resetCurrentGoalProgress();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shuffle_rounded, color: AppTheme.accentGold),
                  title: const Text('Regenerate Random Segments'),
                  subtitle: const Text('Re-roll segment breakdown amounts'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _shuffleCurrentGoalSegments();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.accentRose),
                  title: const Text('Delete Savings Goal'),
                  subtitle: const Text('Permanently remove this goal'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteCurrentGoal();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetCurrentGoalProgress() {
    if (_activeGoal == null) return;
    final resetSegments = _activeGoal!.segments
        .map((s) => s.copyWith(isCompleted: false, completedAt: null, note: null))
        .toList();

    final updated = SavingsGoal(
      id: _activeGoal!.id,
      title: _activeGoal!.title,
      targetAmount: _activeGoal!.targetAmount,
      currencySymbol: _activeGoal!.currencySymbol,
      segmentCount: _activeGoal!.segmentCount,
      distributionType: _activeGoal!.distributionType,
      segments: resetSegments,
      createdAt: _activeGoal!.createdAt,
      targetDate: _activeGoal!.targetDate,
      category: _activeGoal!.category,
      iconName: _activeGoal!.iconName,
      allowCents: _activeGoal!.allowCents,
      colorTheme: _activeGoal!.colorTheme,
    );
    _updateGoalInList(updated);
  }

  void _deleteCurrentGoal() {
    if (_activeGoal == null) return;
    final toRemove = _activeGoal!.id;
    setState(() {
      _goals.removeWhere((g) => g.id == toRemove);
      _activeGoal = _goals.isNotEmpty ? _goals.first : null;
    });
    _saveCurrentState();
  }

  void _openSegmentDetail(SavingsSegment segment) {
    if (_activeGoal == null) return;

    showDialog(
      context: context,
      builder: (context) => SegmentDetailDialog(
        segment: segment,
        currencySymbol: _activeGoal!.currencySymbol,
        allowCents: _activeGoal!.allowCents,
        onSave: (updated) {
          final updatedSegments = _activeGoal!.segments.map((s) {
            return s.id == updated.id ? updated : s;
          }).toList();

          final updatedGoal = SavingsGoal(
            id: _activeGoal!.id,
            title: _activeGoal!.title,
            targetAmount: _activeGoal!.targetAmount,
            currencySymbol: _activeGoal!.currencySymbol,
            segmentCount: _activeGoal!.segmentCount,
            distributionType: _activeGoal!.distributionType,
            segments: updatedSegments,
            createdAt: _activeGoal!.createdAt,
            targetDate: _activeGoal!.targetDate,
            category: _activeGoal!.category,
            iconName: _activeGoal!.iconName,
            allowCents: _activeGoal!.allowCents,
            colorTheme: _activeGoal!.colorTheme,
          );

          _updateGoalInList(updatedGoal);
          if (updatedGoal.isFullyCompleted) {
            _showCelebration(updatedGoal);
          }
        },
      ),
    );
  }

  List<SavingsSegment> _getFilteredAndSortedSegments() {
    if (_activeGoal == null) return [];

    var list = _activeGoal!.segments.where((s) {
      if (_currentFilter == SegmentFilter.saved && !s.isCompleted) return false;
      if (_currentFilter == SegmentFilter.unsaved && s.isCompleted) return false;
      return true;
    }).toList();

    switch (_currentSort) {
      case SegmentSort.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SegmentSort.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SegmentSort.defaultIndex:
        list.sort((a, b) => a.index.compareTo(b.index));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
        ),
      );
    }

    final filteredSegments = _getFilteredAndSortedSegments();

    return ConfettiBurstOverlay(
      trigger: _triggerConfetti,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.warmPeach.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.warmPeach.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppTheme.warmPeach,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Sayver',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                  color: AppTheme.warmPeach,
                ),
              ),
            ],
          ),
          actions: [
            if (_activeGoal != null)
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 20),
                tooltip: 'Share Card',
                onPressed: _openShareDialog,
              ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 20,
              ),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warmPeach,
                  foregroundColor: AppTheme.textDark,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'New Goal',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                onPressed: _openCreateGoalDialog,
              ),
            ),
          ],
          bottom: _goals.isEmpty
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.mutedSlate : AppTheme.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<SavingsGoal>(
                                value: _activeGoal,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                items: _goals.map((goal) {
                                  return DropdownMenuItem<SavingsGoal>(
                                    value: goal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getCategoryIcon(goal.iconName),
                                          size: 18,
                                          color: AppTheme.warmPeach,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            goal.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.softCoral.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${(goal.progressPercentage * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.softCoral,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (goal) {
                                  if (goal != null) {
                                    _setActiveGoal(goal);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        body: _activeGoal == null
            ? _buildEmptyState()
            : Column(
                children: [
                  Container(
                    color: theme.scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.warmPeach,
                      labelColor: AppTheme.warmPeach,
                      unselectedLabelColor: isDark ? AppTheme.textSecondary : Colors.black45,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.grid_view_rounded, size: 20),
                          text: 'Envelopes Grid',
                        ),
                        Tab(
                          icon: Icon(Icons.insights_rounded, size: 20),
                          text: 'Analytics & History',
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GoalHeaderCard(
                                goal: _activeGoal!,
                                onSurprisePick: _openSurprisePicker,
                                onAutoDeposit: _openAutoDeposit,
                                onShuffleSegments: _shuffleCurrentGoalSegments,
                                onEditGoal: _openGoalSettings,
                              ),

                              const SizedBox(height: 14),

                              SavingsJarVisualizer(goal: _activeGoal!),

                              const SizedBox(height: 16),

                              _buildFilterBar(theme, isDark),

                              const SizedBox(height: 14),

                              if (filteredSegments.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Text(
                                      'No envelopes match your filter selection.',
                                      style: TextStyle(
                                        color: isDark ? AppTheme.textSecondary : Colors.black45,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = 3;
                                    if (constraints.maxWidth > 900) {
                                      crossAxisCount = 6;
                                    } else if (constraints.maxWidth > 600) {
                                      crossAxisCount = 4;
                                    } else if (constraints.maxWidth < 360) {
                                      crossAxisCount = 2;
                                    }

                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 1.05,
                                      ),
                                      itemCount: filteredSegments.length,
                                      itemBuilder: (context, index) {
                                        final segment = filteredSegments[index];
                                        return EnvelopeTile(
                                          segment: segment,
                                          currencySymbol:
                                              _activeGoal!.currencySymbol,
                                          allowCents: _activeGoal!.allowCents,
                                          onTap: () =>
                                              _toggleSegmentCompletion(segment),
                                          onLongPress: () =>
                                              _openSegmentDetail(segment),
                                        );
                                      },
                                    );
                                  },
                                ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: AnalyticsView(goal: _activeGoal!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${_activeGoal?.segmentCount ?? 0})',
                  isSelected: _currentFilter == SegmentFilter.all,
                  activeColor: AppTheme.warmPeach,
                  onTap: () => setState(() => _currentFilter = SegmentFilter.all),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Available (${_activeGoal?.segments.where((s) => !s.isCompleted).length ?? 0})',
                  isSelected: _currentFilter == SegmentFilter.unsaved,
                  activeColor: AppTheme.warmPeach,
                  onTap: () => setState(() => _currentFilter = SegmentFilter.unsaved),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Saved (${_activeGoal?.completedCount ?? 0})',
                  isSelected: _currentFilter == SegmentFilter.saved,
                  activeColor: AppTheme.warmPeach,
                  onTap: () => setState(() => _currentFilter = SegmentFilter.saved),
                ),
              ],
            ),
          ),
        ),

        PopupMenuButton<SegmentSort>(
          icon: Icon(
            Icons.sort_rounded,
            size: 20,
            color: isDark ? AppTheme.textSecondary : Colors.black54,
          ),
          tooltip: 'Sort Envelopes',
          onSelected: (sort) {
            setState(() {
              _currentSort = sort;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: SegmentSort.defaultIndex,
              child: Text('Sort by Default Index'),
            ),
            const PopupMenuItem(
              value: SegmentSort.amountAsc,
              child: Text('Sort Amount: Low to High'),
            ),
            const PopupMenuItem(
              value: SegmentSort.amountDesc,
              child: Text('Sort Amount: High to Low'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warmPeach.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 56,
                color: AppTheme.warmPeach,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Active Savings Goal',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first savings goal and watch your target broken down into fun dynamic envelopes!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warmPeach,
                foregroundColor: AppTheme.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create First Goal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: _openCreateGoalDialog,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'shield':
        return Icons.security_rounded;
      case 'mail':
        return Icons.mark_email_unread_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'tech':
        return Icons.laptop_mac_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'savings':
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? AppTheme.mutedSlate : AppTheme.lightCard),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppTheme.borderSlate : AppTheme.lightBorder),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? AppTheme.textDark
                  : (isDark ? AppTheme.textSecondary : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

