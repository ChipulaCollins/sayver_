import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/models/savings_goal.dart';
import 'package:sayver/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Unit Tests', () {
    final mockGoal = SavingsGoal(
      id: 'store_goal_1',
      title: 'Emergency Fund',
      targetAmount: 1000.0,
      currencySymbol: 'K',
      segmentCount: 2,
      segments: [
        SavingsSegment(id: 'seg_1', index: 1, amount: 400.0, isCompleted: true),
        SavingsSegment(id: 'seg_2', index: 2, amount: 600.0, isCompleted: false),
      ],
      createdAt: DateTime(2026, 1, 1),
    );

    test('Loads empty list when no goals stored', () async {
      SharedPreferences.setMockInitialValues({});
      final goals = await StorageService.loadGoals();
      expect(goals, isEmpty);
    });

    test('Saves and loads goals correctly', () async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.saveGoals([mockGoal]);

      final loaded = await StorageService.loadGoals();
      expect(loaded.length, equals(1));
      expect(loaded.first.id, equals('store_goal_1'));
      expect(loaded.first.title, equals('Emergency Fund'));
      expect(loaded.first.targetAmount, equals(1000.0));
      expect(loaded.first.segments.length, equals(2));
    });

    test('Gracefully handles corrupt JSON and falls back to memory storage', () async {
      SharedPreferences.setMockInitialValues({
        'sayver_savings_goals_v3': 'INVALID_NOT_JSON{[',
      });

      // Should not throw, should return memory fallback
      final loaded = await StorageService.loadGoals();
      expect(loaded, isA<List<SavingsGoal>>());
    });

    test('Saves, loads, and clears active goal id properly', () async {
      SharedPreferences.setMockInitialValues({});

      // Initially null
      final initialId = await StorageService.loadActiveGoalId();
      expect(initialId, isNull);

      // Save ID
      await StorageService.saveActiveGoalId('active_123');
      final activeId = await StorageService.loadActiveGoalId();
      expect(activeId, equals('active_123'));

      // Save null clears the ID
      await StorageService.saveActiveGoalId(null);
      final clearedId = await StorageService.loadActiveGoalId();
      expect(clearedId, isNull);
    });

    test('Saves and loads dark mode preference accurately', () async {
      SharedPreferences.setMockInitialValues({});

      // Defaults to true
      final defaultDark = await StorageService.loadDarkMode();
      expect(defaultDark, isTrue);

      // Switch to light mode
      await StorageService.saveDarkMode(false);
      final lightMode = await StorageService.loadDarkMode();
      expect(lightMode, isFalse);

      // Switch back to dark mode
      await StorageService.saveDarkMode(true);
      final darkMode = await StorageService.loadDarkMode();
      expect(darkMode, isTrue);
    });
  });
}
