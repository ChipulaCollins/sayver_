import 'dart:ui';
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

class _HomeScreenState extends State<HomeScreen> {
  List<SavingsGoal> _goals = [];
  SavingsGoal? _activeGoal;
  bool _isLoading = true;
  bool _triggerConfetti = false;

  SegmentFilter _currentFilter = SegmentFilter.all;
  SegmentSort _currentSort = SegmentSort.defaultIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
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
    await StorageService.saveActiveGoalId(_activeGoal?.id);
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
        streakDays: _activeGoal!.currentStreakDays,
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
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
          titleSpacing: 12,
          title: _activeGoal != null
              ? InkWell(
                  onTap: _openGoalSwitcherSheet,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.mutedSlate.withValues(alpha: 0.6)
                          : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.borderSlate.withValues(alpha: 0.8)
                            : AppTheme.lightBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(_activeGoal!.iconName),
                          color: AppTheme.warmPeach,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _activeGoal!.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isDark ? AppTheme.textPrimary : const Color(0xFF231E3D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 17,
                          color: isDark ? AppTheme.textSecondary : Colors.black45,
                        ),
                      ],
                    ),
                  ),
                )
              : const Text(
                  'Sayver',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    color: AppTheme.warmPeach,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 20,
              ),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
            if (_activeGoal != null)
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 20),
                tooltip: 'Goal Settings',
                onPressed: _openGoalSettings,
              ),
            const SizedBox(width: 6),
          ],
        ),

        body: _activeGoal == null
            ? _buildEmptyState()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rapid Stat Pills
                        _buildRapidStatPills(_activeGoal!, isDark),
                        const SizedBox(height: 12),

                        // Zen Hero Header
                        GoalHeaderCard(
                          goal: _activeGoal!,
                          onSurprisePick: _openSurprisePicker,
                          onAutoDeposit: _openAutoDeposit,
                          onShuffleSegments: _shuffleCurrentGoalSegments,
                          onEditGoal: _openGoalSettings,
                          onViewInsights: _openInsightsModal,
                        ),

                        const SizedBox(height: 14),

                        // Segmented Action Pill Toolbar
                        _buildActionToolbar(isDark),

                        const SizedBox(height: 14),

                        // Filter & Sort Pills
                        _buildFilterBar(theme, isDark),

                        const SizedBox(height: 14),

                        // Minimalist Envelope Mesh
                        if (filteredSegments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text(
                                'No envelopes match your filter.',
                                style: TextStyle(
                                  color: isDark ? AppTheme.textSecondary : Colors.black45,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 3;
                              if (constraints.maxWidth > 850) {
                                crossAxisCount = 6;
                              } else if (constraints.maxWidth > 550) {
                                crossAxisCount = 4;
                              } else if (constraints.maxWidth < 310) {
                                crossAxisCount = 2;
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 9,
                                  mainAxisSpacing: 9,
                                  childAspectRatio: 1.15,
                                ),
                                itemCount: filteredSegments.length,
                                itemBuilder: (context, index) {
                                  final segment = filteredSegments[index];
                                  return EnvelopeTile(
                                    segment: segment,
                                    currencySymbol: _activeGoal!.currencySymbol,
                                    allowCents: _activeGoal!.allowCents,
                                    onTap: () => _toggleSegmentCompletion(segment),
                                    onLongPress: () => _openSegmentDetail(segment),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRapidStatPills(SavingsGoal goal, bool isDark) {
    final remStr = goal.allowCents
        ? goal.remainingAmount.toStringAsFixed(2)
        : goal.remainingAmount.toStringAsFixed(0);
    final paceStr = goal.estimatedDailyPace.toStringAsFixed(0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatPill(
            icon: '🔥',
            label: '${goal.currentStreakDays}d',
            isDark: isDark,
            accentColor: AppTheme.warmPeach,
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            icon: '⚡',
            label: '${goal.currencySymbol}$paceStr/d',
            isDark: isDark,
            accentColor: AppTheme.softCoral,
            onTap: _openInsightsModal,
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            icon: '⏳',
            label: '${goal.currencySymbol}$remStr left',
            isDark: isDark,
            accentColor: isDark ? AppTheme.textSecondary : const Color(0xFF48426D),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String icon,
    required String label,
    required bool isDark,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.mutedSlate.withValues(alpha: 0.45)
                : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppTheme.borderSlate.withValues(alpha: 0.5)
                  : AppTheme.lightBorder.withValues(alpha: 0.7),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textPrimary : const Color(0xFF231E3D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionToolbar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.mutedSlate : Colors.white).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? AppTheme.borderSlate : AppTheme.lightBorder).withValues(alpha: 0.8),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Primary Action: Mystery Draw (Glow Warm Peach)
              Expanded(
                flex: 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openSurprisePicker,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.warmPeach, Color(0xFFF3CBA0)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warmPeach.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.casino_rounded, size: 16, color: AppTheme.textDark),
                            SizedBox(width: 5),
                            Text(
                              'Draw',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // 2. Quick Auto-Deposit
              Expanded(
                flex: 2,
                child: _ActionPillButton(
                  icon: Icons.add_circle_outline_rounded,
                  tooltip: 'Auto Deposit',
                  color: AppTheme.softCoral,
                  isDark: isDark,
                  onTap: _openAutoDeposit,
                ),
              ),

              const SizedBox(width: 4),

              // 3. Shuffler
              Expanded(
                flex: 2,
                child: _ActionPillButton(
                  icon: Icons.shuffle_rounded,
                  tooltip: 'Shuffle',
                  color: AppTheme.warmPeach,
                  isDark: isDark,
                  onTap: _shuffleCurrentGoalSegments,
                ),
              ),

              const SizedBox(width: 4),

              // 4. Insights & Jar Visualizer Sheet
              Expanded(
                flex: 2,
                child: _ActionPillButton(
                  icon: Icons.insights_rounded,
                  tooltip: 'Jar & Insights',
                  color: AppTheme.warmPeach,
                  isDark: isDark,
                  onTap: _openInsightsModal,
                ),
              ),

              const SizedBox(width: 4),

              // 5. Create New Goal
              Expanded(
                flex: 2,
                child: _ActionPillButton(
                  icon: Icons.add_rounded,
                  tooltip: 'New Goal',
                  color: isDark ? AppTheme.textSecondary : Colors.black87,
                  isDark: isDark,
                  onTap: _openCreateGoalDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGoalSwitcherSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.mutedSlate : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Savings Goals',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.warmPeach,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New Goal', style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () {
                        Navigator.pop(context);
                        _openCreateGoalDialog();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _goals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final g = _goals[index];
                      final isCurrent = g.id == _activeGoal?.id;
                      return InkWell(
                        onTap: () {
                          _setActiveGoal(g);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppTheme.warmPeach.withValues(alpha: 0.15)
                                : (isDark ? AppTheme.darkNavy.withValues(alpha: 0.4) : AppTheme.lightCard),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrent
                                  ? AppTheme.warmPeach
                                  : (isDark ? AppTheme.borderSlate : AppTheme.lightBorder),
                              width: isCurrent ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(g.iconName),
                                color: isCurrent
                                    ? AppTheme.warmPeach
                                    : (isDark ? AppTheme.textSecondary : Colors.black54),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isCurrent
                                            ? AppTheme.warmPeach
                                            : (isDark ? AppTheme.textPrimary : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${g.currencySymbol} ${g.savedAmount.toInt()} of ${g.currencySymbol} ${g.targetAmount.toInt()} (${(g.progressPercentage * 100).toInt()}%)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.textSecondary : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrent)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.warmPeach,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openInsightsModal() {
    if (_activeGoal == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkNavy : AppTheme.lightBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDark ? AppTheme.borderSlate : AppTheme.lightBorder,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(_activeGoal!.iconName),
                                color: AppTheme.warmPeach,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activeGoal!.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 20),
                          tooltip: 'Share Challenge Card',
                          onPressed: () {
                            Navigator.pop(context);
                            _openShareDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        SavingsJarVisualizer(goal: _activeGoal!),
                        const SizedBox(height: 16),
                        AnalyticsView(goal: _activeGoal!),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionPillButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.16 : 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.3 : 0.15),
                width: 0.8,
              ),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

