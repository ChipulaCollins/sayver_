import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/models/savings_goal.dart';
import 'package:sayver/services/segment_generator.dart';

void main() {
  group('SegmentGenerator tests', () {
    test('Generated segments sum exactly to target amount (Whole dollars)', () {
      double target = 1000.0;
      int count = 25;
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
      double target = 5050.0;
      int count = 100;
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
    });

    test('Generated segments sum exactly with cents enabled', () {
      double target = 250.50;
      int count = 15;
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
      double target = 10.0;
      int count = 20;
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
  });
}
