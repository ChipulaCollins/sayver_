import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/models/savings_goal.dart';
import 'package:sayver/theme/app_theme.dart';
import 'package:sayver/widgets/analytics_view.dart';
import 'package:sayver/widgets/auto_deposit_dialog.dart';
import 'package:sayver/widgets/celebration_dialog.dart';
import 'package:sayver/widgets/envelope_tile.dart';
import 'package:sayver/widgets/goal_header_card.dart';
import 'package:sayver/widgets/savings_jar_visualizer.dart';
import 'package:sayver/widgets/segment_detail_dialog.dart';
import 'package:sayver/widgets/share_progress_dialog.dart';
import 'package:sayver/widgets/surprise_envelope_dialog.dart';

void main() {
  Widget wrapWidget(Widget child, {bool isDark = true}) {
    return MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('EnvelopeTile Widget Tests', () {
    testWidgets('Renders uncompleted envelope with index and amount', (tester) async {
      final seg = SavingsSegment(id: 's1', index: 7, amount: 45.0, isCompleted: false);
      bool tapped = false;
      bool longPressed = false;

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            width: 120,
            height: 120,
            child: EnvelopeTile(
              segment: seg,
              currencySymbol: 'K',
              allowCents: false,
              onTap: () => tapped = true,
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('#7'), findsOneWidget);
      expect(find.text('K 45'), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      await tester.longPress(find.byType(InkWell));
      expect(longPressed, isTrue);
    });

    testWidgets('Renders completed envelope with SAVED badge and checkmark', (tester) async {
      final seg = SavingsSegment(id: 's2', index: 12, amount: 150.0, isCompleted: true);

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            width: 120,
            height: 120,
            child: EnvelopeTile(
              segment: seg,
              currencySymbol: '\$',
              allowCents: false,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('#12'), findsOneWidget);
      expect(find.text('\$ 150'), findsOneWidget);
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('Renders note when present on uncompleted envelope', (tester) async {
      final seg = SavingsSegment(
        id: 's3',
        index: 3,
        amount: 20.0,
        isCompleted: false,
        note: 'Coffee Budget',
      );

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            width: 120,
            height: 120,
            child: EnvelopeTile(
              segment: seg,
              currencySymbol: 'K',
              allowCents: false,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('Coffee Budget'), findsOneWidget);
      expect(find.byIcon(Icons.note_rounded), findsOneWidget);
    });
  });

  group('GoalHeaderCard Widget Tests', () {
    final goal = SavingsGoal(
      id: 'g_header',
      title: 'Car Down Payment',
      targetAmount: 5000.0,
      currencySymbol: 'K',
      segmentCount: 5,
      segments: [
        SavingsSegment(id: 'seg_1', index: 1, amount: 1000.0, isCompleted: true),
        SavingsSegment(id: 'seg_2', index: 2, amount: 1000.0, isCompleted: true),
        SavingsSegment(id: 'seg_3', index: 3, amount: 1000.0, isCompleted: false),
        SavingsSegment(id: 'seg_4', index: 4, amount: 1000.0, isCompleted: false),
        SavingsSegment(id: 'seg_5', index: 5, amount: 1000.0, isCompleted: false),
      ],
      createdAt: DateTime.now(),
    );

    testWidgets('Renders goal progress, target, remaining, and pace correctly', (tester) async {
      bool insightsTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          GoalHeaderCard(
            goal: goal,
            onSurprisePick: () {},
            onAutoDeposit: () {},
            onShuffleSegments: () {},
            onEditGoal: () {},
            onViewInsights: () => insightsTapped = true,
          ),
        ),
      );

      expect(find.text('K 2000'), findsOneWidget); // Saved amount
      expect(find.text('of K 5000'), findsOneWidget); // Target amount
      expect(find.text('40%'), findsOneWidget); // 2000 / 5000 = 40%
      expect(find.text('Remaining: K 3000'), findsOneWidget); // Remaining

      // Tap pace to open insights
      await tester.tap(find.byIcon(Icons.speed_rounded));
      expect(insightsTapped, isTrue);
    });
  });

  group('SavingsJarVisualizer Widget Tests', () {
    testWidgets('Renders milestone badges and daily pace', (tester) async {
      final goal = SavingsGoal(
        id: 'g_jar',
        title: 'New Laptop',
        targetAmount: 1000.0,
        currencySymbol: '\$',
        segmentCount: 4,
        segments: [
          SavingsSegment(id: 'j1', index: 1, amount: 300.0, isCompleted: true),
          SavingsSegment(id: 'j2', index: 2, amount: 300.0, isCompleted: true),
          SavingsSegment(id: 'j3', index: 3, amount: 200.0, isCompleted: false),
          SavingsSegment(id: 'j4', index: 4, amount: 200.0, isCompleted: false),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(wrapWidget(SavingsJarVisualizer(goal: goal)));

      expect(find.text('MILESTONE BADGES'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('AnalyticsView Widget Tests', () {
    testWidgets('Renders metrics grid and empty activity message when no segments saved', (tester) async {
      final goal = SavingsGoal(
        id: 'g_analytics_empty',
        title: 'Emergency Fund',
        targetAmount: 500.0,
        segmentCount: 2,
        segments: [
          SavingsSegment(id: 'a1', index: 1, amount: 250.0, isCompleted: false),
          SavingsSegment(id: 'a2', index: 2, amount: 250.0, isCompleted: false),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(wrapWidget(SingleChildScrollView(child: AnalyticsView(goal: goal))));

      expect(find.text('SAVING STREAK'), findsOneWidget);
      expect(find.text('0 Days'), findsOneWidget);
      expect(find.text('AVG ENVELOPE'), findsOneWidget);
      expect(find.text('No savings activity yet'), findsOneWidget);
    });

    testWidgets('Renders completed segment in savings history', (tester) async {
      final now = DateTime(2026, 6, 1, 14, 0);
      final goal = SavingsGoal(
        id: 'g_analytics_done',
        title: 'Trip to Rome',
        targetAmount: 600.0,
        segmentCount: 2,
        segments: [
          SavingsSegment(id: 'ad1', index: 1, amount: 300.0, isCompleted: true, completedAt: now, note: 'Saved Friday'),
          SavingsSegment(id: 'ad2', index: 2, amount: 300.0, isCompleted: false),
        ],
        createdAt: now,
      );

      await tester.pumpWidget(wrapWidget(SingleChildScrollView(child: AnalyticsView(goal: goal))));

      expect(find.text('Envelope #1'), findsOneWidget);
      expect(find.text('Note: Saved Friday'), findsOneWidget);
    });
  });

  group('Dialogs Tests', () {
    testWidgets('CelebrationDialog displays victory metrics', (tester) async {
      final goal = SavingsGoal(
        id: 'g_celebrate',
        title: 'House Deposit',
        targetAmount: 10000.0,
        segmentCount: 50,
        segments: [],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(wrapWidget(CelebrationDialog(goal: goal)));

      expect(find.text('🎉 GOAL COMPLETED! 🎉'), findsOneWidget);
      expect(find.text('TOTAL SAVED'), findsOneWidget);
      expect(find.text('K10000'), findsOneWidget);
      expect(find.text('Awesome!'), findsOneWidget);
    });

    testWidgets('SegmentDetailDialog allows toggling completion and editing note', (tester) async {
      final seg = SavingsSegment(id: 's_detail', index: 5, amount: 75.0, isCompleted: false);
      SavingsSegment? savedSegment;

      await tester.pumpWidget(
        wrapWidget(
          SegmentDetailDialog(
            segment: seg,
            currencySymbol: 'K',
            allowCents: false,
            onSave: (updated) => savedSegment = updated,
          ),
        ),
      );

      expect(find.text('Envelope #5'), findsOneWidget);
      expect(find.text('K75'), findsOneWidget);

      // Enter a note
      await tester.enterText(find.byType(TextField), 'Lunch savings');

      // Tap Mark as Saved
      await tester.tap(find.text('Mark as Saved'));
      await tester.pump();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(savedSegment, isNotNull);
      expect(savedSegment!.note, equals('Lunch savings'));
      expect(savedSegment!.isCompleted, isTrue);
    });

    testWidgets('ShareProgressDialog displays progress card and copy button', (tester) async {
      final goal = SavingsGoal(
        id: 'g_share',
        title: 'Emergency Fund',
        targetAmount: 1000.0,
        currencySymbol: '\$',
        segmentCount: 10,
        segments: [
          SavingsSegment(id: 's1', index: 1, amount: 100.0, isCompleted: true),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWidget(
          ShareProgressDialog(
            goal: goal,
            streakDays: 3,
          ),
        ),
      );

      expect(find.text('Share Challenge Progress'), findsOneWidget);
      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('Copy Progress Summary'), findsOneWidget);
    });

    testWidgets('AutoDepositDialog matches available envelopes', (tester) async {
      final goal = SavingsGoal(
        id: 'g_deposit',
        title: 'Gadget Goal',
        targetAmount: 500.0,
        segmentCount: 3,
        segments: [
          SavingsSegment(id: 'd1', index: 1, amount: 50.0, isCompleted: false),
          SavingsSegment(id: 'd2', index: 2, amount: 100.0, isCompleted: false),
          SavingsSegment(id: 'd3', index: 3, amount: 200.0, isCompleted: false),
        ],
        createdAt: DateTime.now(),
      );

      List<SavingsSegment>? deposited;

      await tester.pumpWidget(
        wrapWidget(
          AutoDepositDialog(
            goal: goal,
            onDepositSegments: (matched) => deposited = matched,
          ),
        ),
      );

      expect(find.text('Quick Deposit'), findsOneWidget);
      expect(find.textContaining('Complete 1 Envelopes'), findsOneWidget);

      // Tap deposit button
      await tester.tap(find.textContaining('Complete 1 Envelopes'));
      await tester.pump();

      expect(deposited, isNotNull);
      expect(deposited!.length, equals(1));
      expect(deposited!.first.amount, equals(50.0));
    });

    testWidgets('SurpriseEnvelopeDialog reveals random envelope card', (tester) async {
      final goal = SavingsGoal(
        id: 'g_surprise',
        title: 'Surprise Challenge',
        targetAmount: 300.0,
        segmentCount: 2,
        segments: [
          SavingsSegment(id: 'sp1', index: 1, amount: 100.0, isCompleted: false),
          SavingsSegment(id: 'sp2', index: 2, amount: 200.0, isCompleted: false),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWidget(
          SurpriseEnvelopeDialog(
            goal: goal,
            onCompleteSegment: (_) {},
          ),
        ),
      );

      expect(find.text("Today's Envelope"), findsOneWidget);
      expect(find.text('Tap the envelope to reveal today\'s savings amount!'), findsOneWidget);

      // Tap Reveal button
      await tester.tap(find.text('Tap to Open Envelope ✉️'));
      await tester.pumpAndSettle();

      expect(find.text('Here is your savings target for today!'), findsOneWidget);
    });
  });
}
