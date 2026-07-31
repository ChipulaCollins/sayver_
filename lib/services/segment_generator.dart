import 'dart:math';

import '../models/savings_goal.dart';

class SegmentGenerator {
  static final _random = Random();

  /// Generates a list of SavingsSegment items whose total sum EXACTLY equals targetAmount.
  static List<SavingsSegment> generateSegments({
    required String goalId,
    required double targetAmount,
    required int count,
    DistributionType distributionType = DistributionType.random,
    bool allowCents = false,
  }) {
    if (count <= 0) return [];
    final safeTarget = targetAmount <= 0 ? 1.0 : targetAmount;

    if (count == 1) {
      return [
        SavingsSegment(
          id: '${goalId}_seg_0',
          index: 1,
          amount: _roundAmount(safeTarget, allowCents),
        )
      ];
    }

    // Determine if cents are needed because average is < 1.0
    final effectiveAllowCents = allowCents || (safeTarget / count < 1.0);
    final minAllowed = (safeTarget / count) < 1.0
        ? 0.01
        : (effectiveAllowCents ? 0.50 : 1.0);

    List<double> rawAmounts = [];

    switch (distributionType) {
      case DistributionType.envelopeSeries:
        double sumSeries = count * (count + 1) / 2.0;
        for (int i = 1; i <= count; i++) {
          double val = (i / sumSeries) * safeTarget;
          rawAmounts.add(val);
        }
        break;

      case DistributionType.balanced:
        double avg = safeTarget / count;
        double minVal = avg * 0.4;
        double maxVal = avg * 1.6;
        double sum = 0.0;
        for (int i = 0; i < count; i++) {
          double val = minVal + _random.nextDouble() * (maxVal - minVal);
          rawAmounts.add(val);
          sum += val;
        }
        for (int i = 0; i < count; i++) {
          rawAmounts[i] = (rawAmounts[i] / sum) * safeTarget;
        }
        break;

      case DistributionType.random:
        double sum = 0.0;
        for (int i = 0; i < count; i++) {
          double weight = pow(_random.nextDouble(), 1.5).toDouble() + 0.1;
          rawAmounts.add(weight);
          sum += weight;
        }
        for (int i = 0; i < count; i++) {
          rawAmounts[i] = (rawAmounts[i] / sum) * safeTarget;
        }
        break;
    }

    // Step 2: Rounding according to effectiveAllowCents preference
    List<double> roundedAmounts = [];
    double roundedSum = 0.0;

    for (int i = 0; i < count; i++) {
      double r = _roundAmount(rawAmounts[i], effectiveAllowCents);
      if (r < minAllowed) r = minAllowed;
      roundedAmounts.add(r);
      roundedSum += r;
    }

    // Step 3: Exact remainder adjustment (ensure sum(segments) == targetAmount EXACTLY)
    double diff = safeTarget - roundedSum;
    double step = effectiveAllowCents ? 0.01 : 1.0;

    int stepsToAdjust = (diff.abs() / step).round();
    int sign = diff >= 0 ? 1 : -1;

    for (int i = 0; i < stepsToAdjust; i++) {
      int randIndex = _random.nextInt(count);
      if (sign < 0 && roundedAmounts[randIndex] <= minAllowed) {
        int fallbackIndex = roundedAmounts.indexWhere((val) => val > minAllowed);
        if (fallbackIndex != -1) {
          randIndex = fallbackIndex;
        } else {
          break;
        }
      }
      roundedAmounts[randIndex] = _roundAmount(
        roundedAmounts[randIndex] + (sign * step),
        effectiveAllowCents,
      );
    }

    // Final sanity check for double precision drift
    double finalSum = roundedAmounts.fold(0.0, (a, b) => a + b);
    double residual = _roundAmount(safeTarget - finalSum, effectiveAllowCents);
    if (residual.abs() > 0.0001) {
      roundedAmounts[0] = _roundAmount(roundedAmounts[0] + residual, effectiveAllowCents);
    }

    // Shuffle unless user explicitly asked for envelope series
    if (distributionType != DistributionType.envelopeSeries) {
      roundedAmounts.shuffle(_random);
    }

    List<SavingsSegment> segments = [];
    for (int i = 0; i < count; i++) {
      segments.add(
        SavingsSegment(
          id: '${goalId}_seg_$i',
          index: i + 1,
          amount: roundedAmounts[i],
        ),
      );
    }

    return segments;
  }

  static double _roundAmount(double value, bool allowCents) {
    if (allowCents) {
      return (value * 100.0).roundToDouble() / 100.0;
    } else {
      return value.roundToDouble();
    }
  }
}
