import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/models/savings_goal.dart';

void main() {
  group('SavingsSegment Unit Tests', () {
    test('Constructs with defaults and serializes to/from JSON accurately', () {
      final now = DateTime(2026, 5, 1, 10, 30);
      final segment = SavingsSegment(
        id: 'seg_1',
        index: 1,
        amount: 50.0,
        isCompleted: true,
        completedAt: now,
        note: 'Saved from coffee budget',
      );

      final json = segment.toJson();
      expect(json['id'], 'seg_1');
      expect(json['index'], 1);
      expect(json['amount'], 50.0);
      expect(json['isCompleted'], isTrue);
      expect(json['completedAt'], now.toIso8601String());
      expect(json['note'], 'Saved from coffee budget');

      final deserialized = SavingsSegment.fromJson(json);
      expect(deserialized.id, segment.id);
      expect(deserialized.index, segment.index);
      expect(deserialized.amount, segment.amount);
      expect(deserialized.isCompleted, isTrue);
      expect(deserialized.completedAt, equals(now));
      expect(deserialized.note, 'Saved from coffee budget');
    });

    test('copyWith updates specified fields only', () {
      final seg = SavingsSegment(id: 's1', index: 1, amount: 25.0);
      expect(seg.isCompleted, isFalse);
      expect(seg.completedAt, isNull);
      expect(seg.note, isNull);

      final now = DateTime.now();
      final updated = seg.copyWith(
        isCompleted: true,
        completedAt: now,
        note: 'Birthday money',
      );

      expect(updated.id, 's1');
      expect(updated.index, 1);
      expect(updated.amount, 25.0);
      expect(updated.isCompleted, isTrue);
      expect(updated.completedAt, now);
      expect(updated.note, 'Birthday money');
    });
  });

  group('DistributionType Extension Tests', () {
    test('Each distribution type exposes clear label and description', () {
      expect(DistributionType.random.label, equals('Random Variety'));
      expect(DistributionType.random.description, isNotEmpty);

      expect(DistributionType.balanced.label, equals('Balanced Mix'));
      expect(DistributionType.balanced.description, isNotEmpty);

      expect(DistributionType.envelopeSeries.label, equals('Sequential Challenge'));
      expect(DistributionType.envelopeSeries.description, isNotEmpty);
    });
  });

  group('SavingsGoal Model & Metric Calculations', () {
    final t1 = DateTime(2026, 1, 1);
    final segmentsList = [
      SavingsSegment(id: 's1', index: 1, amount: 50.0, isCompleted: true, completedAt: DateTime(2026, 1, 2)),
      SavingsSegment(id: 's2', index: 2, amount: 150.0, isCompleted: true, completedAt: DateTime(2026, 1, 5)),
      SavingsSegment(id: 's3', index: 3, amount: 200.0, isCompleted: false),
      SavingsSegment(id: 's4', index: 4, amount: 100.0, isCompleted: false),
    ];

    test('Calculates savedAmount, remainingAmount, and progressPercentage correctly', () {
      final goal = SavingsGoal(
        id: 'goal_test',
        title: 'MacBook Fund',
        targetAmount: 500.0,
        currencySymbol: '\$',
        segmentCount: 4,
        distributionType: DistributionType.balanced,
        segments: segmentsList,
        createdAt: t1,
        colorTheme: 'cyan',
      );

      // s1(50) + s2(150) = 200 saved
      expect(goal.savedAmount, equals(200.0));
      expect(goal.remainingAmount, equals(300.0));
      expect(goal.progressPercentage, equals(0.4)); // 200 / 500 = 0.4
      expect(goal.completedCount, equals(2));
      expect(goal.isFullyCompleted, isFalse);
    });

    test('Clamps progress percentage between 0.0 and 1.0 even when target is 0 or exceeded', () {
      final zeroTargetGoal = SavingsGoal(
        id: 'g_zero',
        title: 'Zero Target',
        targetAmount: 0.0,
        segmentCount: 1,
        segments: [SavingsSegment(id: 's1', index: 1, amount: 10.0, isCompleted: true)],
        createdAt: t1,
      );
      expect(zeroTargetGoal.progressPercentage, equals(0.0));

      final exceededGoal = SavingsGoal(
        id: 'g_exceeded',
        title: 'Bonus Goal',
        targetAmount: 50.0,
        segmentCount: 1,
        segments: [SavingsSegment(id: 's1', index: 1, amount: 100.0, isCompleted: true)],
        createdAt: t1,
      );
      expect(exceededGoal.progressPercentage, equals(1.0));
      expect(exceededGoal.remainingAmount, equals(0.0));
    });

    test('Reports unlocked milestones based on progress milestones', () {
      SavingsGoal makeGoal(double saved, double target) {
        return SavingsGoal(
          id: 'test_m',
          title: 'Milestone Goal',
          targetAmount: target,
          segmentCount: 1,
          segments: [SavingsSegment(id: 's', index: 1, amount: saved, isCompleted: true)],
          createdAt: t1,
        );
      }

      expect(makeGoal(10, 100).unlockedMilestones, isEmpty);
      expect(makeGoal(25, 100).unlockedMilestones, contains('25% Starter'));
      expect(makeGoal(50, 100).unlockedMilestones, containsAll(['25% Starter', '50% Halfway Champ']));
      expect(makeGoal(75, 100).unlockedMilestones, containsAll(['25% Starter', '50% Halfway Champ', '75% Homestretch']));
      expect(makeGoal(100, 100).unlockedMilestones, containsAll(['25% Starter', '50% Halfway Champ', '75% Homestretch', '100% Goal Master']));
    });

    test('lastSavedAt returns latest completedAt timestamp', () {
      final goal = SavingsGoal(
        id: 'g_dates',
        title: 'Date Order Test',
        targetAmount: 300.0,
        segmentCount: 3,
        segments: [
          SavingsSegment(id: 's1', index: 1, amount: 100, isCompleted: true, completedAt: DateTime(2026, 2, 10)),
          SavingsSegment(id: 's2', index: 2, amount: 100, isCompleted: true, completedAt: DateTime(2026, 3, 15)),
          SavingsSegment(id: 's3', index: 3, amount: 100, isCompleted: false),
        ],
        createdAt: t1,
      );

      expect(goal.lastSavedAt, equals(DateTime(2026, 3, 15)));
    });

    test('primaryColor correctly maps theme strings', () {
      SavingsGoal themeGoal(String theme) => SavingsGoal(
            id: 'tg',
            title: 'Theme',
            targetAmount: 100,
            segmentCount: 1,
            segments: [],
            createdAt: t1,
            colorTheme: theme,
          );

      expect(themeGoal('gold').primaryColor, const Color(0xFFF59E0B));
      expect(themeGoal('cyan').primaryColor, const Color(0xFF06B6D4));
      expect(themeGoal('rose').primaryColor, const Color(0xFFF43F5E));
      expect(themeGoal('purple').primaryColor, const Color(0xFF8B5CF6));
      expect(themeGoal('emerald').primaryColor, const Color(0xFF10B981));
      expect(themeGoal('unknown').primaryColor, const Color(0xFF10B981));
    });

    test('estimatedDailyPace handles target dates correctly', () {
      final now = DateTime.now();
      final inTenDays = now.add(const Duration(days: 10));
      final pastDate = now.subtract(const Duration(days: 5));

      final goalWithDate = SavingsGoal(
        id: 'g_pace_future',
        title: 'Future Pace',
        targetAmount: 1000.0,
        segmentCount: 1,
        segments: [SavingsSegment(id: 's1', index: 1, amount: 0)],
        createdAt: now,
        targetDate: inTenDays,
      );
      // 1000 remaining / ~10 days = ~100
      expect(goalWithDate.estimatedDailyPace, closeTo(100.0, 15.0));

      final goalWithPastDate = SavingsGoal(
        id: 'g_pace_past',
        title: 'Past Pace',
        targetAmount: 500.0,
        segmentCount: 1,
        segments: [SavingsSegment(id: 's1', index: 1, amount: 0)],
        createdAt: now,
        targetDate: pastDate,
      );
      // Days <= 0 defaults to 1, pace = 500 / 1 = 500
      expect(goalWithPastDate.estimatedDailyPace, equals(500.0));

      final goalWithoutDate = SavingsGoal(
        id: 'g_pace_none',
        title: 'Default 30 Days Pace',
        targetAmount: 600.0,
        segmentCount: 1,
        segments: [SavingsSegment(id: 's1', index: 1, amount: 0)],
        createdAt: now,
      );
      // Defaults to 30 days: 600 / 30 = 20
      expect(goalWithoutDate.estimatedDailyPace, equals(20.0));
    });

    test('Full JSON serialization and round-trip preservation', () {
      final now = DateTime(2026, 4, 15, 12, 0);
      final targetD = DateTime(2026, 12, 31);
      final original = SavingsGoal(
        id: 'roundtrip_1',
        title: 'Trip to Tokyo',
        targetAmount: 3500.0,
        currencySymbol: '¥',
        segmentCount: 2,
        distributionType: DistributionType.envelopeSeries,
        segments: [
          SavingsSegment(id: 'rt_s1', index: 1, amount: 1500.0, isCompleted: true, completedAt: now, note: 'Saved!'),
          SavingsSegment(id: 'rt_s2', index: 2, amount: 2000.0, isCompleted: false),
        ],
        createdAt: now,
        targetDate: targetD,
        category: 'Travel',
        iconName: 'flight',
        allowCents: true,
        colorTheme: 'rose',
      );

      final json = original.toJson();
      final reconstructed = SavingsGoal.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.title, equals(original.title));
      expect(reconstructed.targetAmount, equals(original.targetAmount));
      expect(reconstructed.currencySymbol, equals(original.currencySymbol));
      expect(reconstructed.segmentCount, equals(original.segmentCount));
      expect(reconstructed.distributionType, equals(DistributionType.envelopeSeries));
      expect(reconstructed.segments.length, equals(2));
      expect(reconstructed.segments[0].amount, equals(1500.0));
      expect(reconstructed.segments[0].note, equals('Saved!'));
      expect(reconstructed.segments[1].amount, equals(2000.0));
      expect(reconstructed.createdAt, equals(now));
      expect(reconstructed.targetDate, equals(targetD));
      expect(reconstructed.category, equals('Travel'));
      expect(reconstructed.iconName, equals('flight'));
      expect(reconstructed.allowCents, isTrue);
      expect(reconstructed.colorTheme, equals('rose'));
    });
  });
}
