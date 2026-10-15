import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/main.dart';
import 'package:sayver/models/savings_goal.dart';
import 'package:sayver/services/storage_service.dart';
import 'package:sayver/widgets/analytics_view.dart';
import 'package:sayver/widgets/auto_deposit_dialog.dart';
import 'package:sayver/widgets/celebration_dialog.dart';
import 'package:sayver/widgets/create_goal_dialog.dart';
import 'package:sayver/widgets/envelope_tile.dart';
import 'package:sayver/widgets/goal_header_card.dart';
import 'package:sayver/widgets/savings_jar_visualizer.dart';
import 'package:sayver/widgets/segment_detail_dialog.dart';
import 'package:sayver/widgets/share_progress_dialog.dart';
import 'package:sayver/widgets/surprise_envelope_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

SavingsGoal createAdversarialGoal({
  String id = 'adv_goal_1',
  String title = 'Adversarial Vault',
  double targetAmount = 1000.0,
  int segmentCount = 6,
  int completedCount = 0,
  bool allowCents = false,
  String currencySymbol = 'K',
  String category = 'Emergency',
  String iconName = 'shield',
  String colorTheme = 'emerald',
  DateTime? createdAt,
  DateTime? targetDate,
}) {
  final segments = <SavingsSegment>[];
  final perSegment = targetAmount / (segmentCount > 0 ? segmentCount : 1);
  for (int i = 0; i < segmentCount; i++) {
    final isDone = i < completedCount;
    segments.add(
      SavingsSegment(
        id: '${id}_seg_$i',
        index: i + 1,
        amount: perSegment,
        isCompleted: isDone,
        completedAt: isDone ? DateTime.now().subtract(Duration(days: completedCount - i)) : null,
        note: isDone ? 'Deposit #$i' : null,
      ),
    );
  }

  return SavingsGoal(
    id: id,
    title: title,
    targetAmount: targetAmount,
    currencySymbol: currencySymbol,
    segmentCount: segmentCount,
    distributionType: DistributionType.random,
    segments: segments,
    createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 10)),
    targetDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
    category: category,
    iconName: iconName,
    allowCents: allowCents,
    colorTheme: colorTheme,
  );
}

Future<void> pumpAdversarialApp(
  WidgetTester tester, {
  List<SavingsGoal>? goals,
  String? activeGoalId,
  bool isDarkMode = true,
  Size? viewport,
}) async {
  if (viewport != null) {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final effectiveGoals = goals ?? [createAdversarialGoal()];
  final effectiveActiveId = activeGoalId ?? (effectiveGoals.isNotEmpty ? effectiveGoals.first.id : null);

  final prefsMap = <String, Object>{
    'sayver_dark_mode_v1': isDarkMode,
    'sayver_savings_goals_v3': jsonEncode(effectiveGoals.map((g) => g.toJson()).toList()),
  };
  if (effectiveActiveId != null) {
    prefsMap['sayver_active_goal_id_v3'] = effectiveActiveId;
  }

  SharedPreferences.setMockInitialValues(prefsMap);
  await StorageService.saveGoals(effectiveGoals);
  await StorageService.saveActiveGoalId(effectiveActiveId);
  await StorageService.saveDarkMode(isDarkMode);

  await tester.pumpWidget(const SayverApp());
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

Finder findTileInkWell(WidgetTester tester, int index) {
  return find.descendant(
    of: find.byType(EnvelopeTile).at(index),
    matching: find.byType(InkWell),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group 1: Extreme Viewport Boundaries (280px to 2560px+)', () {
    testWidgets('1.1 Ultra-compact mobile 280x653 renders dashboard without RenderFlex overflow', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 6);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(280, 653));

      expect(tester.takeException(), isNull);
      expect(find.byType(GoalHeaderCard), findsOneWidget);
      expect(find.byType(EnvelopeTile), findsNWidgets(6));

      // Tap an envelope tile in 280px viewport
      await tester.tap(findTileInkWell(tester, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.2 Ultra-compact short viewport 280x480 scrolls cleanly without overflow', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 12);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(280, 480));

      expect(tester.takeException(), isNull);

      // Scroll down on short viewport
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3 Ultra-wide 4K desktop 2560x1440 enforces maxWidth constraint and 6-column mesh', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 18);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(2560, 1440));

      expect(tester.takeException(), isNull);

      final constrainedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is ConstrainedBox && widget.constraints.maxWidth == 1040,
      );
      expect(constrainedBoxFinder, findsWidgets);

      // Verify grid adapts to 6 columns
      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);
      final gridView = tester.widget<GridView>(gridViewFinder);
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(6));
    });

    testWidgets('1.4 Dynamic viewport resizing from 2560px down to 280px mid-session', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 8);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(2560, 1440));

      // Dynamic resize to tablet
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Dynamic resize to ultra-compact
      tester.view.physicalSize = const Size(280, 653);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Re-expand to full HD
      tester.view.physicalSize = const Size(1920, 1080);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.5 CreateGoalDialog renders and scrolls without overflow on 280x653', (tester) async {
      await pumpAdversarialApp(tester, goals: [], viewport: const Size(280, 653));

      await tester.tap(find.text('Create First Goal'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateGoalDialog), findsOneWidget);
      expect(find.text('New Savings Goal'), findsOneWidget);

      // Switch to Tab 2
      await tester.tap(find.text('2. Style & Custom'));
      await tester.pumpAndSettle();
      expect(find.text('ACCENT COLOR THEME'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.6 AutoDepositDialog matches and deposits without overflow on 280x653', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 6);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(280, 653));

      await tester.tap(find.byTooltip('Auto Deposit'));
      await tester.pumpAndSettle();

      expect(find.byType(AutoDepositDialog), findsOneWidget);
      expect(find.text('Quick Deposit'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tap Deposit button
      await tester.tap(find.textContaining('Deposit'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.7 SurpriseEnvelopeDialog flips 3D card without overflow on 280x653', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 6);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(280, 653));

      await tester.tap(find.text('Draw'));
      await tester.pumpAndSettle();

      expect(find.byType(SurpriseEnvelopeDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tap to open envelope
      await tester.tap(find.text('Tap to Open Envelope ✉️'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Save Now!'), findsOneWidget);
    });

    testWidgets('1.8 SegmentDetailDialog opens and saves note without overflow on 280x653', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 4);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(280, 653));

      // Long press envelope
      await tester.longPress(findTileInkWell(tester, 0));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentDetailDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Enter a note and save
      await tester.enterText(find.byType(TextField), 'Adversarial Test Note');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Adversarial Test Note'), findsOneWidget);
    });

    testWidgets('1.9 GoalSwitcher and GoalSettings sheets open without overflow on 280x653', (tester) async {
      final goal1 = createAdversarialGoal(id: 'g1', title: 'Main Emergency Fund');
      final goal2 = createAdversarialGoal(id: 'g2', title: 'Secondary Vacation Goal');
      await pumpAdversarialApp(tester, goals: [goal1, goal2], viewport: const Size(280, 653));

      // Open Goal Switcher
      await tester.tap(find.text('Main Emergency Fund'));
      await tester.pumpAndSettle();
      expect(find.text('Savings Goals'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch to goal 2
      await tester.tap(find.text('Secondary Vacation Goal'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Secondary Vacation Goal'), findsWidgets);

      // Open Goal Settings
      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Share Progress Card'), findsOneWidget);
      expect(find.text('Reset Goal Progress'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.10 Insights modal with DraggableScrollableSheet renders on 280x653', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 8, completedCount: 3);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(280, 653));

      await tester.tap(find.byTooltip('Jar & Insights'));
      await tester.pumpAndSettle();

      expect(find.byType(SavingsJarVisualizer), findsOneWidget);
      expect(find.byType(AnalyticsView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Group 2: Rapid Multi-Tap & Concurrent Gesture Sequences', () {
    testWidgets('2.1 Rapid consecutive taps on single envelope toggle completion safely', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 4, completedCount: 0);
      await pumpAdversarialApp(tester, goals: [goal]);

      final tileFinder = findTileInkWell(tester, 0);

      // Tap 10 times consecutively with short pumps
      for (int i = 0; i < 10; i++) {
        await tester.tap(tileFinder);
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // 10 taps on initially uncompleted envelope leaves it uncompleted (even number of toggles)
      expect(find.text('Saved (0)'), findsOneWidget);
    });

    testWidgets('2.2 Rapid multi-envelope sequential completion triggers accurate state', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 4, completedCount: 0);
      await pumpAdversarialApp(tester, goals: [goal]);

      // Tap 3 different envelopes rapidly
      for (int i = 0; i < 3; i++) {
        await tester.tap(findTileInkWell(tester, i));
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Saved (3)'), findsOneWidget);
      expect(find.text('Available (1)'), findsOneWidget);
    });

    testWidgets('2.3 Concurrent multi-touch gesture on adjacent envelopes', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 4, completedCount: 0);
      await pumpAdversarialApp(tester, goals: [goal]);

      final tile1 = findTileInkWell(tester, 0);
      final tile2 = findTileInkWell(tester, 1);

      final pointer1 = await tester.startGesture(tester.getCenter(tile1), pointer: 1);
      final pointer2 = await tester.startGesture(tester.getCenter(tile2), pointer: 2);
      await tester.pump(const Duration(milliseconds: 50));
      await pointer1.up();
      await pointer2.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Saved (2)'), findsOneWidget);
    });

    testWidgets('2.4 Rapid spamming on toolbar action pills does not corrupt navigator', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 4);
      await pumpAdversarialApp(tester, goals: [goal]);

      // Rapidly tap Shuffle
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byTooltip('Shuffle'));
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Rapidly tap Draw and immediately dismiss
      await tester.tap(find.text('Draw'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.byType(SurpriseEnvelopeDialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SurpriseEnvelopeDialog), findsNothing);
    });

    testWidgets('2.5 Final envelope completion opens CelebrationDialog safely under multi-tap', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 2, completedCount: 1);
      await pumpAdversarialApp(tester, goals: [goal]);

      // Complete the remaining envelope
      final lastTile = findTileInkWell(tester, 1);
      await tester.tap(lastTile);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byType(CelebrationDialog), findsOneWidget);
      expect(find.text('🎉 GOAL COMPLETED! 🎉'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Dismiss celebration
      await tester.tap(find.text('Awesome!'));
      await tester.pumpAndSettle();
      expect(find.byType(CelebrationDialog), findsNothing);
    });
  });

  group('Group 3: Extreme Currencies, Amounts & Formatting', () {
    testWidgets('3.1 Multi-character currency symbol USDT renders across all components', (tester) async {
      final goal = createAdversarialGoal(
        currencySymbol: 'USDT',
        targetAmount: 50000.0,
        segmentCount: 4,
        allowCents: true,
      );
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(360, 640));

      expect(find.textContaining('USDT'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3.2 Astronomical target amount 999,999,999.99 scales cleanly without overflow', (tester) async {
      final goal = createAdversarialGoal(
        targetAmount: 999999999.99,
        segmentCount: 4,
        allowCents: true,
        currencySymbol: '\$',
      );
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(320, 568));

      expect(find.byType(GoalHeaderCard), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Open share dialog with astronomical amounts
      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share Progress Card'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareProgressDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3.3 Micro-target amount with tiny decimal segments', (tester) async {
      final goal = createAdversarialGoal(
        targetAmount: 0.05,
        segmentCount: 5,
        allowCents: true,
        currencySymbol: '€',
      );
      await pumpAdversarialApp(tester, goals: [goal]);

      expect(tester.takeException(), isNull);
      expect(find.text('€ 0.01'), findsWidgets);

      // Tap one micro segment
      await tester.tap(findTileInkWell(tester, 0));
      await tester.pumpAndSettle();
      expect(find.text('Saved (1)'), findsOneWidget);
    });

    testWidgets('3.4 Unicode currency symbols (Thai Baht ฿)', (tester) async {
      final goal = createAdversarialGoal(currencySymbol: '฿', targetAmount: 777.0, segmentCount: 3);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(360, 640));

      expect(find.textContaining('฿'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3.5 Polish Zloty (zł) and Yen (¥)', (tester) async {
      final goal = createAdversarialGoal(currencySymbol: 'zł', targetAmount: 500.0, segmentCount: 2);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(360, 640));

      expect(find.textContaining('zł'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3.6 Empty string currency symbol handles formatting gracefully', (tester) async {
      final goal = createAdversarialGoal(currencySymbol: '', targetAmount: 250.0, segmentCount: 2);
      await pumpAdversarialApp(tester, goals: [goal]);

      expect(tester.takeException(), isNull);
      expect(find.byType(EnvelopeTile), findsNWidgets(2));
    });

    testWidgets('3.7 Extremely long goal title (100+ characters) truncates safely', (tester) async {
      const longTitle = 'Supercalifragilisticexpialidocious Long Term Strategic Ultra Multi-Year Family Emergency Resilience Fund 2030';
      final goal = createAdversarialGoal(title: longTitle, segmentCount: 4);
      await pumpAdversarialApp(tester, goals: [goal], viewport: const Size(320, 568));

      expect(tester.takeException(), isNull);
      expect(find.byType(GoalHeaderCard), findsOneWidget);
    });
  });

  group('Group 4: High-Frequency Theme Toggling Under Dynamic Conditions', () {
    testWidgets('4.1 High-frequency theme toggling (20 consecutive switches)', (tester) async {
      final goal = createAdversarialGoal();
      await pumpAdversarialApp(tester, goals: [goal]);

      final themeToggle = find.byTooltip('Toggle Theme');
      for (int i = 0; i < 20; i++) {
        await tester.tap(themeToggle);
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('4.2 Theme toggle while CreateGoalDialog is mounted', (tester) async {
      await pumpAdversarialApp(tester, goals: []);

      await tester.tap(find.text('Create First Goal'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateGoalDialog), findsOneWidget);

      // Trigger theme toggle programmatically on HomeScreen while dialog is open
      final homeState = tester.widget<HomeScreen>(find.byType(HomeScreen));
      homeState.onToggleTheme();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CreateGoalDialog), findsOneWidget);

      // Re-toggle back
      homeState.onToggleTheme();
      await tester.pumpAndSettle();
      expect(find.byType(CreateGoalDialog), findsOneWidget);
    });

    testWidgets('4.3 Theme toggle while AutoDepositDialog is mounted', (tester) async {
      final goal = createAdversarialGoal();
      await pumpAdversarialApp(tester, goals: [goal]);

      await tester.tap(find.byTooltip('Auto Deposit'));
      await tester.pumpAndSettle();
      expect(find.byType(AutoDepositDialog), findsOneWidget);

      final homeState = tester.widget<HomeScreen>(find.byType(HomeScreen));
      homeState.onToggleTheme();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AutoDepositDialog), findsOneWidget);
    });

    testWidgets('4.4 Theme toggle during SurpriseEnvelopeDialog flip animation', (tester) async {
      final goal = createAdversarialGoal();
      await pumpAdversarialApp(tester, goals: [goal]);

      await tester.tap(find.text('Draw'));
      await tester.pumpAndSettle();

      // Tap to open envelope (starts flip animation)
      await tester.tap(find.text('Tap to Open Envelope ✉️'));
      await tester.pump(const Duration(milliseconds: 150));

      // Toggle theme mid-animation
      final homeState = tester.widget<HomeScreen>(find.byType(HomeScreen));
      homeState.onToggleTheme();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SurpriseEnvelopeDialog), findsOneWidget);
    });

    testWidgets('4.5 Theme toggle while Insights modal sheet is open', (tester) async {
      final goal = createAdversarialGoal();
      await pumpAdversarialApp(tester, goals: [goal]);

      await tester.tap(find.byTooltip('Jar & Insights'));
      await tester.pumpAndSettle();

      expect(find.byType(SavingsJarVisualizer), findsOneWidget);

      final homeState = tester.widget<HomeScreen>(find.byType(HomeScreen));
      homeState.onToggleTheme();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SavingsJarVisualizer), findsOneWidget);
    });
  });

  group('Group 5: Edge-Case State Mutations & Boundary Invariants', () {
    testWidgets('5.1 Target date in distant past and future does not produce NaN/Infinity pace', (tester) async {
      final pastGoal = createAdversarialGoal(
        id: 'past_1',
        title: 'Past Goal',
        targetDate: DateTime.now().subtract(const Duration(days: 365)),
      );
      final futureGoal = createAdversarialGoal(
        id: 'future_1',
        title: 'Future Goal',
        targetDate: DateTime.now().add(const Duration(days: 3650)),
      );

      await pumpAdversarialApp(tester, goals: [pastGoal, futureGoal]);
      expect(tester.takeException(), isNull);
      expect(pastGoal.estimatedDailyPace.isFinite, isTrue);
      expect(pastGoal.estimatedDailyPace >= 0, isTrue);

      expect(futureGoal.estimatedDailyPace.isFinite, isTrue);
      expect(futureGoal.estimatedDailyPace >= 0, isTrue);
    });

    testWidgets('5.2 Goal with 100 envelopes scrolls and filters without performance degradation', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 100, completedCount: 50);
      await pumpAdversarialApp(tester, goals: [goal]);

      expect(find.text('All (100)'), findsOneWidget);
      expect(find.text('Saved (50)'), findsOneWidget);
      expect(find.text('Available (50)'), findsOneWidget);

      // Filter Saved
      await tester.tap(find.text('Saved (50)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Filter Available
      await tester.tap(find.text('Available (50)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('5.3 Shuffling goal segments preserves total sum invariant', (tester) async {
      final goal = createAdversarialGoal(targetAmount: 1234.56, segmentCount: 10, allowCents: true);
      await pumpAdversarialApp(tester, goals: [goal]);

      await tester.tap(find.byTooltip('Shuffle'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Segments reshuffled with exact total sum preserved!'), findsOneWidget);
    });

    testWidgets('5.4 Reset goal progress clears all completed segments', (tester) async {
      final goal = createAdversarialGoal(segmentCount: 4, completedCount: 3);
      await pumpAdversarialApp(tester, goals: [goal]);

      expect(find.text('Saved (3)'), findsOneWidget);

      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset Goal Progress'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Saved (0)'), findsOneWidget);
    });

    testWidgets('5.5 Deleting active goal transitions cleanly to remaining goal or empty state', (tester) async {
      final soleGoal = createAdversarialGoal(id: 'sole_1', title: 'Sole Active Goal');
      await pumpAdversarialApp(tester, goals: [soleGoal]);

      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Savings Goal'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No Active Savings Goal'), findsOneWidget);
      expect(find.text('Create First Goal'), findsOneWidget);
    });
  });
}
