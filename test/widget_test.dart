import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/main.dart';
import 'package:sayver/models/savings_goal.dart';
import 'package:sayver/widgets/envelope_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SavingsGoal createMockGoal({String id = 'mock_1', String title = 'Emergency Fund'}) {
    return SavingsGoal(
      id: id,
      title: title,
      targetAmount: 500.0,
      segmentCount: 5,
      segments: [
        SavingsSegment(id: '${id}_seg_0', index: 1, amount: 100.0, isCompleted: true),
        SavingsSegment(id: '${id}_seg_1', index: 2, amount: 100.0, isCompleted: false),
        SavingsSegment(id: '${id}_seg_2', index: 3, amount: 100.0, isCompleted: false),
        SavingsSegment(id: '${id}_seg_3', index: 4, amount: 100.0, isCompleted: false),
        SavingsSegment(id: '${id}_seg_4', index: 5, amount: 100.0, isCompleted: false),
      ],
      createdAt: DateTime.now(),
    );
  }

  testWidgets('Sayver App initial smoke test (Empty state)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sayver'), findsOneWidget);
    expect(find.text('No Active Savings Goal'), findsOneWidget);
    expect(find.text('Create First Goal'), findsOneWidget);

    // Tap Create First Goal opens dialog
    await tester.tap(find.text('Create First Goal'));
    await tester.pumpAndSettle();
    expect(find.text('New Savings Goal'), findsOneWidget);
  });

  testWidgets('Sayver App renders Zen Canvas and Floating Dock with active goal', (WidgetTester tester) async {
    final mockGoal = createMockGoal();

    SharedPreferences.setMockInitialValues({
      'sayver_savings_goals_v3': jsonEncode([mockGoal.toJson()]),
      'sayver_active_goal_id_v3': 'mock_1',
    });

    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify goal switcher pill displays title
    expect(find.text('Emergency Fund'), findsOneWidget);

    // Verify Zen Hero displays target
    expect(find.text('of K 500'), findsOneWidget);

    // Verify Floating Command Capsule displays primary action
    expect(find.text('Draw'), findsOneWidget);

    // Verify envelopes rendered in grid
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
  });

  testWidgets('Tapping uncompleted envelope tile completes it and updates state', (WidgetTester tester) async {
    final mockGoal = createMockGoal();

    SharedPreferences.setMockInitialValues({
      'sayver_savings_goals_v3': jsonEncode([mockGoal.toJson()]),
      'sayver_active_goal_id_v3': 'mock_1',
    });

    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Find envelope #2 (which is uncompleted)
    final envelope2Finder = find.ancestor(
      of: find.text('#2'),
      matching: find.byType(EnvelopeTile),
    );
    expect(envelope2Finder, findsOneWidget);

    // Tap envelope #2
    await tester.tap(find.descendant(of: envelope2Finder, matching: find.byType(InkWell)));
    await tester.pumpAndSettle();

    // Verify progress is updated to 2 of 5 envelopes
    expect(find.text('Saved (2)'), findsOneWidget);
  });

  testWidgets('Filter pills filter envelope mesh accurately', (WidgetTester tester) async {
    final mockGoal = createMockGoal();

    SharedPreferences.setMockInitialValues({
      'sayver_savings_goals_v3': jsonEncode([mockGoal.toJson()]),
      'sayver_active_goal_id_v3': 'mock_1',
    });

    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Initially all 5 are shown
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);

    // Tap 'Saved (1)' filter
    await tester.tap(find.text('Saved (1)'));
    await tester.pumpAndSettle();

    // Only #1 was saved
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsNothing);

    // Tap 'Available (4)' filter
    await tester.tap(find.text('Available (4)'));
    await tester.pumpAndSettle();

    expect(find.text('#1'), findsNothing);
    expect(find.text('#2'), findsOneWidget);
  });

  testWidgets('Theme toggle switches theme dynamically', (WidgetTester tester) async {
    final mockGoal = createMockGoal();

    SharedPreferences.setMockInitialValues({
      'sayver_savings_goals_v3': jsonEncode([mockGoal.toJson()]),
      'sayver_active_goal_id_v3': 'mock_1',
      'sayver_dark_mode_v1': true,
    });

    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Tap theme toggle icon
    final themeToggleFinder = find.byTooltip('Toggle Theme');
    expect(themeToggleFinder, findsOneWidget);

    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('sayver_dark_mode_v1'), isFalse);
  });

  testWidgets('Goal switcher opens bottom sheet and displays multiple goals', (WidgetTester tester) async {
    final goal1 = createMockGoal(id: 'g1', title: 'Car Fund');
    final goal2 = createMockGoal(id: 'g2', title: 'Vacation Fund');

    SharedPreferences.setMockInitialValues({
      'sayver_savings_goals_v3': jsonEncode([goal1.toJson(), goal2.toJson()]),
      'sayver_active_goal_id_v3': 'g1',
    });

    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Tap goal switcher pill
    await tester.tap(find.text('Car Fund'));
    await tester.pumpAndSettle();

    // Verify bottom sheet displays both goals
    expect(find.text('Savings Goals'), findsOneWidget);
    expect(find.text('Vacation Fund'), findsOneWidget);

    // Switch to Vacation Fund
    await tester.tap(find.text('Vacation Fund'));
    await tester.pumpAndSettle();

    // Main screen now displays Vacation Fund
    expect(find.text('Vacation Fund'), findsOneWidget);
  });
}
