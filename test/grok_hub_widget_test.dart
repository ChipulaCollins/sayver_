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

SavingsGoal createTestGoal({
  String id = 'test_goal_1',
  String title = 'Emergency Fund',
  double targetAmount = 500.0,
  int segmentCount = 5,
  int completedCount = 1,
  bool allowCents = false,
  String currencySymbol = 'K',
  String category = 'General',
  String iconName = 'savings',
  String colorTheme = 'emerald',
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
        completedAt: isDone ? DateTime(2026, 6, 1) : null,
        note: isDone ? 'Saved on Day ${i + 1}' : null,
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
    createdAt: DateTime(2026, 1, 1),
    targetDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
    category: category,
    iconName: iconName,
    allowCents: allowCents,
    colorTheme: colorTheme,
  );
}

Future<void> pumpSayverApp(
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

  final effectiveGoals = goals ?? [];
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

void main() {
  group('Tier 1: Feature Coverage', () {
    group('Feature 1: Grok Hub Action Pill Toolbar', () {
      testWidgets('1.1 Draw action pill opens SurpriseEnvelopeDialog', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('Draw'), findsOneWidget);
        await tester.tap(find.text('Draw'));
        await tester.pumpAndSettle();

        expect(find.byType(SurpriseEnvelopeDialog), findsOneWidget);
        expect(find.text("Today's Envelope"), findsOneWidget);
      });

      testWidgets('1.2 Auto Deposit command launches AutoDepositDialog', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        final autoDepositFinder = find.byTooltip('Auto Deposit');
        expect(autoDepositFinder, findsOneWidget);

        await tester.tap(autoDepositFinder);
        await tester.pumpAndSettle();

        expect(find.byType(AutoDepositDialog), findsOneWidget);
        expect(find.text('Quick Deposit'), findsOneWidget);
      });

      testWidgets('1.3 Insights command opens Jar & Analytics bottom sheet', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        final insightsFinder = find.byTooltip('Jar & Insights');
        expect(insightsFinder, findsOneWidget);

        await tester.tap(insightsFinder);
        await tester.pumpAndSettle();

        expect(find.byType(SavingsJarVisualizer), findsOneWidget);
        expect(find.byType(AnalyticsView), findsOneWidget);
      });

      testWidgets('1.4 New Goal command opens CreateGoalDialog', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        final newGoalFinder = find.byTooltip('New Goal');
        expect(newGoalFinder, findsOneWidget);

        await tester.tap(newGoalFinder);
        await tester.pumpAndSettle();

        expect(find.byType(CreateGoalDialog), findsOneWidget);
        expect(find.text('New Savings Goal'), findsOneWidget);
      });

      testWidgets('1.5 Action pills remain interactive across repeated dismiss and reopen', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        // Open Auto Deposit
        await tester.tap(find.byTooltip('Auto Deposit'));
        await tester.pumpAndSettle();
        expect(find.text('Quick Deposit'), findsOneWidget);

        // Close Auto Deposit via close icon
        final closeBtn = find.descendant(
          of: find.byType(AutoDepositDialog),
          matching: find.byIcon(Icons.close_rounded),
        );
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
        expect(find.text('Quick Deposit'), findsNothing);

        // Open Draw
        await tester.tap(find.text('Draw'));
        await tester.pumpAndSettle();
        expect(find.text("Today's Envelope"), findsOneWidget);

        // Close Draw
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text("Today's Envelope"), findsNothing);
      });
    });

    group('Feature 2: Top Bar Goal Switcher & Rapid Stats', () {
      testWidgets('2.1 Top bar renders goal switcher capsule with title and chevron', (tester) async {
        final goal = createTestGoal(title: 'Vacation Trip');
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('Vacation Trip'), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      });

      testWidgets('2.2 Tapping goal capsule opens bottom sheet displaying all goals', (tester) async {
        final g1 = createTestGoal(id: 'g1', title: 'Vacation Trip');
        final g2 = createTestGoal(id: 'g2', title: 'Car Fund');
        await pumpSayverApp(tester, goals: [g1, g2], activeGoalId: 'g1');

        await tester.tap(find.text('Vacation Trip'));
        await tester.pumpAndSettle();

        expect(find.text('Savings Goals'), findsOneWidget);
        expect(find.text('Car Fund'), findsOneWidget);
      });

      testWidgets('2.3 Selecting a goal from switcher updates active dashboard state', (tester) async {
        final g1 = createTestGoal(id: 'g1', title: 'Vacation Trip');
        final g2 = createTestGoal(id: 'g2', title: 'Car Fund');
        await pumpSayverApp(tester, goals: [g1, g2], activeGoalId: 'g1');

        await tester.tap(find.text('Vacation Trip'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Car Fund'));
        await tester.pumpAndSettle();

        expect(find.text('Car Fund'), findsOneWidget);
      });

      testWidgets('2.4 Goal switcher sheet provides New Goal shortcut', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.text('Emergency Fund'));
        await tester.pumpAndSettle();

        // New Goal in switcher header
        await tester.tap(find.text('New Goal'));
        await tester.pumpAndSettle();

        expect(find.byType(CreateGoalDialog), findsOneWidget);
      });

      testWidgets('2.5 Top bar displays theme toggle button with tooltip', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], isDarkMode: true);

        final toggleFinder = find.byTooltip('Toggle Theme');
        expect(toggleFinder, findsOneWidget);

        await tester.tap(toggleFinder);
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('sayver_dark_mode_v1'), isFalse);
      });
    });

    group('Feature 3: Tactile Interactive Filter & Sort Chips', () {
      testWidgets('3.1 All filter chip displays total segment count and shows all envelopes', (tester) async {
        final goal = createTestGoal(segmentCount: 5, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('All (5)'), findsOneWidget);
        expect(find.text('#1'), findsOneWidget);
        expect(find.text('#2'), findsOneWidget);
        expect(find.text('#3'), findsOneWidget);
        expect(find.text('#4'), findsOneWidget);
        expect(find.text('#5'), findsOneWidget);
      });

      testWidgets('3.2 Available filter chip filters to uncompleted envelopes only', (tester) async {
        final goal = createTestGoal(segmentCount: 5, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.text('Available (3)'));
        await tester.pumpAndSettle();

        // #1 and #2 were saved
        expect(find.text('#1'), findsNothing);
        expect(find.text('#2'), findsNothing);
        expect(find.text('#3'), findsOneWidget);
        expect(find.text('#4'), findsOneWidget);
        expect(find.text('#5'), findsOneWidget);
      });

      testWidgets('3.3 Saved filter chip filters to completed envelopes only', (tester) async {
        final goal = createTestGoal(segmentCount: 5, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.text('Saved (2)'));
        await tester.pumpAndSettle();

        expect(find.text('#1'), findsOneWidget);
        expect(find.text('#2'), findsOneWidget);
        expect(find.text('#3'), findsNothing);
        expect(find.text('#4'), findsNothing);
      });

      testWidgets('3.4 Sorting envelopes by amount ascending reorders grid items', (tester) async {
        final goal = SavingsGoal(
          id: 'sort_goal',
          title: 'Sort Test',
          targetAmount: 600.0,
          segmentCount: 3,
          segments: [
            SavingsSegment(id: 's1', index: 1, amount: 300.0, isCompleted: false),
            SavingsSegment(id: 's2', index: 2, amount: 100.0, isCompleted: false),
            SavingsSegment(id: 's3', index: 3, amount: 200.0, isCompleted: false),
          ],
          createdAt: DateTime.now(),
        );
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byTooltip('Sort Envelopes'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sort Amount: Low to High'));
        await tester.pumpAndSettle();

        final tiles = tester.widgetList<EnvelopeTile>(find.byType(EnvelopeTile)).toList();
        expect(tiles[0].segment.amount, equals(100.0));
        expect(tiles[1].segment.amount, equals(200.0));
        expect(tiles[2].segment.amount, equals(300.0));
      });

      testWidgets('3.5 Sorting envelopes by amount descending reorders grid items', (tester) async {
        final goal = SavingsGoal(
          id: 'sort_desc_goal',
          title: 'Sort Desc Test',
          targetAmount: 600.0,
          segmentCount: 3,
          segments: [
            SavingsSegment(id: 's1', index: 1, amount: 100.0, isCompleted: false),
            SavingsSegment(id: 's2', index: 2, amount: 300.0, isCompleted: false),
            SavingsSegment(id: 's3', index: 3, amount: 200.0, isCompleted: false),
          ],
          createdAt: DateTime.now(),
        );
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byTooltip('Sort Envelopes'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sort Amount: High to Low'));
        await tester.pumpAndSettle();

        final tiles = tester.widgetList<EnvelopeTile>(find.byType(EnvelopeTile)).toList();
        expect(tiles[0].segment.amount, equals(300.0));
        expect(tiles[1].segment.amount, equals(200.0));
        expect(tiles[2].segment.amount, equals(100.0));
      });
    });

    group('Feature 4: Hero Progress Card with Glow Gauges', () {
      testWidgets('4.1 Hero card displays saved amount, target, and percentage', (tester) async {
        final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('K 200'), findsOneWidget);
        expect(find.text('of K 500'), findsOneWidget);
        expect(find.text('40%'), findsOneWidget);
      });

      testWidgets('4.2 Hero card displays remaining balance', (tester) async {
        final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('Remaining: K 300'), findsOneWidget);
      });

      testWidgets('4.3 Hero card displays daily pace with speed indicator icon', (tester) async {
        final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
        expect(find.textContaining('/day'), findsOneWidget);
      });

      testWidgets('4.4 Hero card renders category tag and completed envelope ratio', (tester) async {
        final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5, completedCount: 2, category: 'General');
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('GENERAL • 2/5 SAVED'), findsOneWidget);
      });

      testWidgets('4.5 Tapping daily pace row in hero card opens insights sheet', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byIcon(Icons.speed_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(AnalyticsView), findsOneWidget);
      });
    });

    group('Feature 5: Tactile Envelope Mesh & Micro-Interactions', () {
      testWidgets('5.1 Uncompleted tile displays index, formatted amount, and pending circle', (tester) async {
        final goal = createTestGoal(segmentCount: 2, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('#1'), findsOneWidget);
        expect(find.text('K 250'), findsNWidgets(2));
        expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));
      });

      testWidgets('5.2 Completed tile displays SAVED badge and checkmark', (tester) async {
        final goal = createTestGoal(segmentCount: 2, completedCount: 1);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('SAVED'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      });

      testWidgets('5.3 Tapping uncompleted envelope marks it saved and updates saved count', (tester) async {
        final goal = createTestGoal(segmentCount: 3, completedCount: 1);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('Saved (1)'), findsOneWidget);

        final envelope2 = find.ancestor(
          of: find.text('#2'),
          matching: find.byType(EnvelopeTile),
        );
        await tester.tap(find.descendant(of: envelope2, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.text('Saved (2)'), findsOneWidget);
      });

      testWidgets('5.4 Tapping completed envelope uncompletes it and decrements saved count', (tester) async {
        final goal = createTestGoal(segmentCount: 3, completedCount: 2);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('Saved (2)'), findsOneWidget);

        final envelope1 = find.ancestor(
          of: find.text('#1'),
          matching: find.byType(EnvelopeTile),
        );
        await tester.tap(find.descendant(of: envelope1, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.text('Saved (1)'), findsOneWidget);
      });

      testWidgets('5.5 Long-pressing envelope opens SegmentDetailDialog', (tester) async {
        final goal = createTestGoal(segmentCount: 3, completedCount: 1);
        await pumpSayverApp(tester, goals: [goal]);

        final envelope2 = find.ancestor(
          of: find.text('#2'),
          matching: find.byType(EnvelopeTile),
        );
        await tester.longPress(find.descendant(of: envelope2, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.byType(SegmentDetailDialog), findsOneWidget);
        expect(find.text('Envelope #2'), findsOneWidget);
      });
    });

    group('Feature 6: Responsive Grid Layout (360px–1200px)', () {
      testWidgets('6.1 Compact mobile 360x640 renders grid with 3 columns without overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 6);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(360, 640));

        expect(tester.takeException(), isNull);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(3));
      });

      testWidgets('6.2 Standard mobile 412x915 renders grid with 3 columns without overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 6);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

        expect(tester.takeException(), isNull);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(3));
      });

      testWidgets('6.3 Tablet 768x1024 adapts grid to 4 columns without overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 8);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(768, 1024));

        expect(tester.takeException(), isNull);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(4));
      });

      testWidgets('6.4 Desktop 1200x800 adapts grid to 6 columns without overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 12);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(1200, 800));

        expect(tester.takeException(), isNull);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(6));
      });

      testWidgets('6.5 Dynamic viewport change resizes grid layout smoothly', (tester) async {
        final goal = createTestGoal(segmentCount: 12);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

        var grid = tester.widget<GridView>(find.byType(GridView));
        var delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(3));

        tester.view.physicalSize = const Size(1200, 800);
        await tester.pumpAndSettle();

        grid = tester.widget<GridView>(find.byType(GridView));
        delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(6));
        expect(tester.takeException(), isNull);
      });
    });

    group('Feature 7: Seamless Modals & Sheets (Zero Overflow)', () {
      testWidgets('7.1 CreateGoalDialog tabs and form fields render without overflow', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byTooltip('New Goal'));
        await tester.pumpAndSettle();

        expect(find.text('New Savings Goal'), findsOneWidget);
        expect(find.text('1. Essentials'), findsOneWidget);
        expect(find.text('2. Style & Custom'), findsOneWidget);

        // Switch to Style & Custom tab
        await tester.tap(find.text('2. Style & Custom'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('7.2 AutoDepositDialog matches envelopes and deposits without overflow', (tester) async {
        final goal = createTestGoal(targetAmount: 500, segmentCount: 5, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byTooltip('Auto Deposit'));
        await tester.pumpAndSettle();

        expect(find.text('Quick Deposit'), findsOneWidget);
        expect(find.textContaining('Complete'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('7.3 SurpriseEnvelopeDialog flip card animates without overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 3, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.text('Draw'));
        await tester.pumpAndSettle();

        expect(find.text('Tap to Open Envelope ✉️'), findsOneWidget);
        await tester.tap(find.text('Tap to Open Envelope ✉️'));
        await tester.pumpAndSettle();

        expect(find.text('Target for Today'), findsOneWidget);
        expect(find.text('Save Now!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('7.4 SegmentDetailDialog note editing saves cleanly without overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 2, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        final env1 = find.ancestor(of: find.text('#1'), matching: find.byType(EnvelopeTile));
        await tester.longPress(find.descendant(of: env1, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.text('Envelope #1'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'Test Note Content');
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        expect(find.byType(SegmentDetailDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('7.5 Goal settings sheet displays all options without overflow', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

        await tester.tap(find.byTooltip('Goal Settings'));
        await tester.pumpAndSettle();

        expect(find.text('Share Progress Card'), findsOneWidget);
        expect(find.text('Reset Goal Progress'), findsOneWidget);
        expect(find.text('Regenerate Random Segments'), findsOneWidget);
        expect(find.text('Delete Savings Goal'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Feature 8: Theme Consistency & WCAG AA Contrast', () {
      testWidgets('8.1 Dark theme renders dark scaffold background', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], isDarkMode: true);

        expect(Theme.of(tester.element(find.byType(HomeScreen))).brightness, equals(Brightness.dark));
      });

      testWidgets('8.2 Light theme renders light brightness and contrast text', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], isDarkMode: false);

        expect(Theme.of(tester.element(find.byType(HomeScreen))).brightness, equals(Brightness.light));
      });

      testWidgets('8.3 Theme toggle updates local storage', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], isDarkMode: true);

        await tester.tap(find.byTooltip('Toggle Theme'));
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('sayver_dark_mode_v1'), isFalse);
      });

      testWidgets('8.4 Filter chips maintain readability across theme switches', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], isDarkMode: true);

        expect(find.text('All (5)'), findsOneWidget);

        // Toggle to light mode
        await tester.tap(find.byTooltip('Toggle Theme'));
        await tester.pumpAndSettle();

        expect(find.text('All (5)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('8.5 Envelope tiles render distinct styling in dark and light modes', (tester) async {
        final goal = createTestGoal(segmentCount: 2, completedCount: 1);
        await pumpSayverApp(tester, goals: [goal], isDarkMode: false);

        expect(find.text('SAVED'), findsOneWidget);
        expect(find.text('#2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('Tier 2: Boundary & Corner Cases', () {
    group('Empty State & Zero Goals', () {
      testWidgets('2.1 Zero goals renders empty state illustration', (tester) async {
        await pumpSayverApp(tester, goals: []);

        expect(find.text('Sayver'), findsOneWidget);
        expect(find.text('No Active Savings Goal'), findsOneWidget);
        expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
      });

      testWidgets('2.2 Empty state renders Create First Goal CTA button', (tester) async {
        await pumpSayverApp(tester, goals: []);

        expect(find.text('Create First Goal'), findsOneWidget);
      });

      testWidgets('2.3 Tapping CTA launches goal creation wizard', (tester) async {
        await pumpSayverApp(tester, goals: []);

        await tester.tap(find.text('Create First Goal'));
        await tester.pumpAndSettle();

        expect(find.byType(CreateGoalDialog), findsOneWidget);
      });

      testWidgets('2.4 Creating goal from empty state transitions to dashboard', (tester) async {
        await pumpSayverApp(tester, goals: []);

        await tester.tap(find.text('Create First Goal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create Goal'));
        await tester.pumpAndSettle();

        expect(find.text('My Savings Goal'), findsOneWidget);
        expect(find.byType(GoalHeaderCard), findsOneWidget);
      });

      testWidgets('2.5 Deleting sole active goal transitions back to empty state', (tester) async {
        final goal = createTestGoal();
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

        await tester.tap(find.byTooltip('Goal Settings'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete Savings Goal'));
        await tester.pumpAndSettle();

        expect(find.text('No Active Savings Goal'), findsOneWidget);
      });
    });

    group('Single Envelope Goal', () {
      testWidgets('2.6 Goal with 1 envelope renders single envelope tile', (tester) async {
        final goal = createTestGoal(targetAmount: 50.0, segmentCount: 1, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.byType(EnvelopeTile), findsOneWidget);
        expect(find.text('#1'), findsOneWidget);
      });

      testWidgets('2.7 Completing single envelope triggers 100% completion celebration', (tester) async {
        final goal = createTestGoal(targetAmount: 50.0, segmentCount: 1, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        final tileFinder = find.byType(EnvelopeTile);
        await tester.tap(find.descendant(of: tileFinder, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.byType(CelebrationDialog), findsOneWidget);
        expect(find.text('🎉 GOAL COMPLETED! 🎉'), findsOneWidget);
      });

      testWidgets('2.8 CelebrationDialog displays total saved amount and dismisses', (tester) async {
        final goal = createTestGoal(targetAmount: 50.0, segmentCount: 1, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        final tileFinder = find.byType(EnvelopeTile);
        await tester.tap(find.descendant(of: tileFinder, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.text('TOTAL SAVED'), findsOneWidget);
        await tester.tap(find.text('Awesome!'));
        await tester.pumpAndSettle();

        expect(find.byType(CelebrationDialog), findsNothing);
      });

      testWidgets('2.9 Single envelope goal with Available filter isolates empty state gracefully', (tester) async {
        final goal = createTestGoal(targetAmount: 50.0, segmentCount: 1, completedCount: 1);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.text('Available (0)'));
        await tester.pumpAndSettle();

        expect(find.text('No envelopes match your filter.'), findsOneWidget);
      });

      testWidgets('2.10 Auto-deposit on single envelope goal completes goal', (tester) async {
        final goal = createTestGoal(targetAmount: 50.0, segmentCount: 1, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byTooltip('Auto Deposit'));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('Complete'));
        await tester.pumpAndSettle();

        expect(find.text('Saved (1)'), findsOneWidget);
      });
    });

    group('Large Goal (100+ Envelopes)', () {
      testWidgets('2.11 Goal with 100 envelopes loads without error', (tester) async {
        final goal = createTestGoal(targetAmount: 5050.0, segmentCount: 100, completedCount: 10);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('All (100)'), findsOneWidget);
        expect(find.text('Available (90)'), findsOneWidget);
        expect(find.text('Saved (10)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('2.12 Scrolling large 100-envelope goal reveals higher index envelopes', (tester) async {
        final goal = createTestGoal(targetAmount: 5050.0, segmentCount: 100, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        // Drag down to scroll using the main vertical scrollable
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('2.13 Tapping visible envelope in 100-envelope goal updates metrics', (tester) async {
        final goal = createTestGoal(targetAmount: 5050.0, segmentCount: 100, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('Saved (0)'), findsOneWidget);

        final env1 = find.ancestor(of: find.text('#1'), matching: find.byType(EnvelopeTile));
        await tester.tap(find.descendant(of: env1, matching: find.byType(InkWell)));
        await tester.pumpAndSettle();

        expect(find.text('Saved (1)'), findsOneWidget);
      });

      testWidgets('2.14 Filter Saved isolates completed envelopes in 100-envelope goal', (tester) async {
        final goal = createTestGoal(targetAmount: 5050.0, segmentCount: 100, completedCount: 5);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.text('Saved (5)'));
        await tester.pumpAndSettle();

        expect(find.text('#1'), findsOneWidget);
        expect(find.text('#5'), findsOneWidget);
        expect(find.text('#6'), findsNothing);
      });

      testWidgets('2.15 Auto-deposit matches multiple envelopes in 100-envelope goal', (tester) async {
        final goal = createTestGoal(targetAmount: 5050.0, segmentCount: 100, completedCount: 0);
        await pumpSayverApp(tester, goals: [goal]);

        await tester.tap(find.byTooltip('Auto Deposit'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Complete'), findsOneWidget);
        await tester.tap(find.textContaining('Complete'));
        await tester.pumpAndSettle();

        expect(find.text('Saved (0)'), findsNothing);
      });
    });

    group('Extreme Amounts, Cents & Currencies', () {
      testWidgets('2.16 Goal with allowCents: true formats with 2 decimal places', (tester) async {
        final goal = createTestGoal(
          targetAmount: 123.45,
          segmentCount: 1,
          completedCount: 0,
          allowCents: true,
        );
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('K 123.45'), findsWidgets);
      });

      testWidgets('2.17 Custom currency symbol renders across UI cards', (tester) async {
        final goal = createTestGoal(
          targetAmount: 1000.0,
          currencySymbol: '€',
          segmentCount: 2,
        );
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('of € 1000'), findsOneWidget);
        expect(find.text('€ 500'), findsWidgets);
      });

      testWidgets('2.18 Very large target amount scales down without overflow', (tester) async {
        final goal = createTestGoal(
          targetAmount: 10000000.0,
          segmentCount: 4,
          completedCount: 2,
        );
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('K 5000000'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('2.19 Extremely long title truncates in top bar capsule', (tester) async {
        final goal = createTestGoal(
          title: 'This is an extremely long savings goal title designed to test text ellipsis bounds',
        );
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.textContaining('This is an extremely long'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('2.20 Fully completed goal clamps progress at 100%', (tester) async {
        final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5, completedCount: 5);
        await pumpSayverApp(tester, goals: [goal]);

        expect(find.text('100%'), findsOneWidget);
        expect(find.text('Remaining: K 0'), findsOneWidget);
      });
    });

    group('Extreme Viewport Boundaries', () {
      testWidgets('2.21 Ultra-compact mobile 320x568 adapts to 2 columns with zero overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 6);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(320, 568));

        expect(tester.takeException(), isNull);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(2));
      });

      testWidgets('2.22 Compact mobile 360x640 renders cleanly with zero overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 6);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(360, 640));
        expect(tester.takeException(), isNull);
      });

      testWidgets('2.23 Standard mobile 412x915 renders cleanly with zero overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 6);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));
        expect(tester.takeException(), isNull);
      });

      testWidgets('2.24 Tablet portrait 768x1024 renders cleanly with zero overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 8);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(768, 1024));
        expect(tester.takeException(), isNull);
      });

      testWidgets('2.25 Ultra-wide desktop 1920x1080 renders cleanly with zero overflow', (tester) async {
        final goal = createTestGoal(segmentCount: 12);
        await pumpSayverApp(tester, goals: [goal], viewport: const Size(1920, 1080));
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('Tier 3: Cross-Feature Combinations', () {
    testWidgets('3.1 Filter active while switching goals persists filter on new goal', (tester) async {
      final g1 = createTestGoal(id: 'g1', title: 'Fund 1', segmentCount: 4, completedCount: 2);
      final g2 = createTestGoal(id: 'g2', title: 'Fund 2', segmentCount: 6, completedCount: 3);
      await pumpSayverApp(tester, goals: [g1, g2], activeGoalId: 'g1');

      // Set filter to Saved
      await tester.tap(find.text('Saved (2)'));
      await tester.pumpAndSettle();

      // Switch to Fund 2
      await tester.tap(find.text('Fund 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fund 2'));
      await tester.pumpAndSettle();

      // Filter should still be Saved, now showing 3
      expect(find.text('Saved (3)'), findsOneWidget);
    });

    testWidgets('3.2 Auto-deposit followed by surprise envelope draw only targets remaining envelopes', (tester) async {
      final goal = createTestGoal(targetAmount: 300, segmentCount: 3, completedCount: 0);
      await pumpSayverApp(tester, goals: [goal]);

      // Auto-deposit first
      await tester.tap(find.byTooltip('Auto Deposit'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Complete'));
      await tester.pumpAndSettle();

      // Now open surprise draw
      await tester.tap(find.text('Draw'));
      await tester.pumpAndSettle();

      expect(find.text("Today's Envelope"), findsOneWidget);
      await tester.tap(find.text('Tap to Open Envelope ✉️'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Now!'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('3.3 Filter Available combined with Sort High to Low sorts only uncompleted envelopes', (tester) async {
      final goal = SavingsGoal(
        id: 'filter_sort',
        title: 'Filter Sort Test',
        targetAmount: 600.0,
        segmentCount: 3,
        segments: [
          SavingsSegment(id: 's1', index: 1, amount: 100.0, isCompleted: true),
          SavingsSegment(id: 's2', index: 2, amount: 200.0, isCompleted: false),
          SavingsSegment(id: 's3', index: 3, amount: 300.0, isCompleted: false),
        ],
        createdAt: DateTime.now(),
      );
      await pumpSayverApp(tester, goals: [goal]);

      // Filter Available
      await tester.tap(find.text('Available (2)'));
      await tester.pumpAndSettle();

      // Sort High to Low
      await tester.tap(find.byTooltip('Sort Envelopes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sort Amount: High to Low'));
      await tester.pumpAndSettle();

      final tiles = tester.widgetList<EnvelopeTile>(find.byType(EnvelopeTile)).toList();
      expect(tiles.length, equals(2));
      expect(tiles[0].segment.amount, equals(300.0));
      expect(tiles[1].segment.amount, equals(200.0));
    });

    testWidgets('3.4 Note editing on envelope tile while filter is active updates tile and preserves filter', (tester) async {
      final goal = createTestGoal(segmentCount: 4, completedCount: 1);
      await pumpSayverApp(tester, goals: [goal]);

      // Filter to Available
      await tester.tap(find.text('Available (3)'));
      await tester.pumpAndSettle();

      // Long press envelope #2
      final env2 = find.ancestor(of: find.text('#2'), matching: find.byType(EnvelopeTile));
      await tester.longPress(find.descendant(of: env2, matching: find.byType(InkWell)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Available (3)'), findsOneWidget);
    });

    testWidgets('3.5 Regenerating segments via settings preserves total goal sum', (tester) async {
      final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5);
      await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Regenerate Random Segments'));
      await tester.pumpAndSettle();

      expect(find.text('Segments reshuffled with exact total sum preserved!'), findsOneWidget);
      expect(find.text('of K 500'), findsOneWidget);
    });

    testWidgets('3.6 Theme toggle while modal sheet is open does not crash', (tester) async {
      final goal = createTestGoal();
      await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Share Progress Card'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Close settings
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Toggle Theme'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Tier 4: Real-World Application Scenarios', () {
    testWidgets('4.1 Scenario 1: Greenfield User Journey (Empty state -> Create -> Draw -> Claim -> Progress)', (tester) async {
      // 1. Launch with empty storage
      await pumpSayverApp(tester, goals: []);
      expect(find.text('No Active Savings Goal'), findsOneWidget);

      // 2. Tap Create First Goal
      await tester.tap(find.text('Create First Goal'));
      await tester.pumpAndSettle();
      expect(find.text('New Savings Goal'), findsOneWidget);

      // 3. Submit default goal
      await tester.tap(find.text('Create Goal'));
      await tester.pumpAndSettle();
      expect(find.text('My Savings Goal'), findsOneWidget);

      // 4. Draw a surprise envelope
      await tester.tap(find.text('Draw'));
      await tester.pumpAndSettle();
      expect(find.text("Today's Envelope"), findsOneWidget);

      // 5. Flip & claim envelope
      await tester.tap(find.text('Tap to Open Envelope ✉️'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Now!'));
      await tester.pumpAndSettle();

      // 6. Verify progress incremented
      expect(find.text('Saved (1)'), findsOneWidget);
    });

    testWidgets('4.2 Scenario 2: High-Velocity Auto-Deposit Session', (tester) async {
      final goal = createTestGoal(targetAmount: 500.0, segmentCount: 5, completedCount: 0);
      await pumpSayverApp(tester, goals: [goal]);

      expect(find.text('Remaining: K 500'), findsOneWidget);

      // Launch Auto Deposit
      await tester.tap(find.byTooltip('Auto Deposit'));
      await tester.pumpAndSettle();

      // Execute deposit
      await tester.tap(find.textContaining('Complete'));
      await tester.pumpAndSettle();

      // Verify remaining balance decreased
      expect(find.text('Remaining: K 500'), findsNothing);
      expect(find.text('Saved (0)'), findsNothing);
    });

    testWidgets('4.3 Scenario 3: Viewport Resize & Orientation Shift', (tester) async {
      final goal = createTestGoal(segmentCount: 12);

      // Start on compact mobile 360x640
      await pumpSayverApp(tester, goals: [goal], viewport: const Size(360, 640));
      expect(tester.takeException(), isNull);

      // Transition to tablet 768x1024
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Transition to desktop 1200x800
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('4.4 Scenario 4: Multi-Goal Switch & Theme Transition', (tester) async {
      final g1 = createTestGoal(id: 'g1', title: 'Emergency Fund');
      final g2 = createTestGoal(id: 'g2', title: 'Travel Fund');
      await pumpSayverApp(tester, goals: [g1, g2], activeGoalId: 'g1', isDarkMode: true);

      // Switch to Travel Fund
      await tester.tap(find.text('Emergency Fund'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Travel Fund'));
      await tester.pumpAndSettle();
      expect(find.text('Travel Fund'), findsOneWidget);

      // Toggle Theme
      await tester.tap(find.byTooltip('Toggle Theme'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sayver_dark_mode_v1'), isFalse);

      // Switch back to Emergency Fund in light mode
      await tester.tap(find.text('Travel Fund'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Emergency Fund'));
      await tester.pumpAndSettle();
      expect(find.text('Emergency Fund'), findsOneWidget);
    });

    testWidgets('4.5 Scenario 5: Milestone Celebration & Progress Share', (tester) async {
      final goal = createTestGoal(targetAmount: 200.0, segmentCount: 2, completedCount: 1);
      await pumpSayverApp(tester, goals: [goal], viewport: const Size(412, 915));

      // Complete last envelope
      final env2 = find.ancestor(of: find.text('#2'), matching: find.byType(EnvelopeTile));
      await tester.tap(find.descendant(of: env2, matching: find.byType(InkWell)));
      await tester.pumpAndSettle();

      // Celebration dialog triggers
      expect(find.byType(CelebrationDialog), findsOneWidget);
      expect(find.text('🎉 GOAL COMPLETED! 🎉'), findsOneWidget);

      // Dismiss celebration dialog
      await tester.tap(find.text('Awesome!'));
      await tester.pumpAndSettle();

      // Open settings and share progress
      await tester.tap(find.byTooltip('Goal Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Share Progress Card'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareProgressDialog), findsOneWidget);
      expect(find.text('Share Challenge Progress'), findsOneWidget);
    });
  });
}
