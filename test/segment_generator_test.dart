import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/models/savings_goal.dart';
import 'package:sayver/services/segment_generator.dart';

void main() {
  group('SegmentGenerator Comprehensive Tests', () {
    test('Generated segments sum exactly to target amount (Whole dollars)', () {
      const double target = 1000.0;
      const int count = 25;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'test_1',
        targetAmount: target,
        count: count,
        distributionType: DistributionType.random,
        allowCents: false,
      );

      expect(segments.length, equals(count));
      double sum = segments.fold(0.0, (prev, curr) => prev + curr.amount);
      expect(sum, equals(target));
      for (var seg in segments) {
        expect(seg.amount, greaterThanOrEqualTo(1.0));
        expect(seg.amount, equals(seg.amount.roundToDouble()));
      }
    });

    test('100 Envelope Challenge exact target calculation', () {
      const double target = 5050.0;
      const int count = 100;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'test_100',
        targetAmount: target,
        count: count,
        distributionType: DistributionType.envelopeSeries,
        allowCents: false,
      );

      expect(segments.length, equals(100));
      double sum = segments.fold(0.0, (prev, curr) => prev + curr.amount);
      expect(sum, equals(target));

      // In envelopeSeries, segments should be in non-decreasing order
      for (int i = 0; i < segments.length - 1; i++) {
        expect(segments[i].amount, lessThanOrEqualTo(segments[i + 1].amount));
      }
    });

    test('52-Week Challenge exact calculation and progression', () {
      // 52 * 53 / 2 = 1378
      const double target = 1378.0;
      const int count = 52;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'test_52week',
        targetAmount: target,
        count: count,
        distributionType: DistributionType.envelopeSeries,
        allowCents: false,
      );

      expect(segments.length, equals(52));
      double sum = segments.fold(0.0, (prev, curr) => prev + curr.amount);
      expect(sum, equals(target));
      expect(segments.first.amount, equals(1.0));
      expect(segments.last.amount, equals(52.0));
    });

    test('Generated segments sum exactly with cents enabled and arbitrary target', () {
      const double target = 789.37;
      const int count = 33;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'test_cents',
        targetAmount: target,
        count: count,
        distributionType: DistributionType.balanced,
        allowCents: true,
      );

      expect(segments.length, equals(count));
      double sum = segments.fold(0.0, (prev, curr) => prev + curr.amount);
      expect((sum - target).abs(), lessThan(0.001));
    });

    test('Small target amount smaller than segment count handles exact sum', () {
      const double target = 10.0;
      const int count = 20;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'test_small',
        targetAmount: target,
        count: count,
        distributionType: DistributionType.random,
        allowCents: false,
      );

      expect(segments.length, equals(count));
      double sum = segments.fold(0.0, (prev, curr) => prev + curr.amount);
      expect((sum - target).abs(), lessThan(0.001));
    });

    test('Single segment count returns exact single envelope', () {
      const double target = 250.0;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'single_seg',
        targetAmount: target,
        count: 1,
      );

      expect(segments.length, equals(1));
      expect(segments.first.id, equals('single_seg_seg_0'));
      expect(segments.first.index, equals(1));
      expect(segments.first.amount, equals(250.0));
    });

    test('Count <= 0 safely returns empty list without error', () {
      final segmentsZero = SegmentGenerator.generateSegments(
        goalId: 'zero_count',
        targetAmount: 100.0,
        count: 0,
      );
      expect(segmentsZero, isEmpty);

      final segmentsNegative = SegmentGenerator.generateSegments(
        goalId: 'neg_count',
        targetAmount: 100.0,
        count: -5,
      );
      expect(segmentsNegative, isEmpty);
    });

    test('Large target amounts scale properly and sum exactly', () {
      const double target = 100000.0;
      const int count = 100;
      final segments = SegmentGenerator.generateSegments(
        goalId: 'large_goal',
        targetAmount: target,
        count: count,
        distributionType: DistributionType.random,
      );

      expect(segments.length, equals(100));
      double sum = segments.fold(0.0, (prev, curr) => prev + curr.amount);
      expect(sum, equals(target));
    });
  });
}
