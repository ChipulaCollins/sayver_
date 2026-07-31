import 'package:flutter/material.dart';

enum DistributionType {
  random,
  balanced,
  envelopeSeries,
}

extension DistributionTypeExtension on DistributionType {
  String get label {
    switch (this) {
      case DistributionType.random:
        return 'Random Variety';
      case DistributionType.balanced:
        return 'Balanced Mix';
      case DistributionType.envelopeSeries:
        return 'Sequential Challenge';
    }
  }

  String get description {
    switch (this) {
      case DistributionType.random:
        return 'Wild variation of small and large amounts for fun surprises.';
      case DistributionType.balanced:
        return 'A smoother mix centered around average daily savings.';
      case DistributionType.envelopeSeries:
        return 'Gradual progression from smallest to largest values.';
    }
  }
}

class SavingsSegment {
  final String id;
  final int index;
  final double amount;
  bool isCompleted;
  DateTime? completedAt;
  String? note;

  SavingsSegment({
    required this.id,
    required this.index,
    required this.amount,
    this.isCompleted = false,
    this.completedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'amount': amount,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'note': note,
      };

  factory SavingsSegment.fromJson(Map<String, dynamic> json) => SavingsSegment(
        id: json['id'] as String,
        index: json['index'] as int,
        amount: (json['amount'] as num).toDouble(),
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        note: json['note'] as String?,
      );

  SavingsSegment copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    String? note,
  }) {
    return SavingsSegment(
      id: id,
      index: index,
      amount: amount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
    );
  }
}

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final String currencySymbol;
  final int segmentCount;
  final DistributionType distributionType;
  final List<SavingsSegment> segments;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String category;
  final String iconName;
  final bool allowCents;
  final String colorTheme; // 'emerald', 'gold', 'cyan', 'rose', 'purple'

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currencySymbol = 'K',
    required this.segmentCount,
    this.distributionType = DistributionType.random,
    required this.segments,
    required this.createdAt,
    this.targetDate,
    this.category = 'General',
    this.iconName = 'savings',
    this.allowCents = false,
    this.colorTheme = 'emerald',
  });

  double get savedAmount {
    return segments
        .where((s) => s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  double get remainingAmount {
    final rem = targetAmount - savedAmount;
    return rem < 0 ? 0.0 : rem;
  }

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final ratio = savedAmount / targetAmount;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  int get completedCount {
    return segments.where((s) => s.isCompleted).length;
  }

  bool get isFullyCompleted {
    return completedCount == segments.length;
  }

  Color get primaryColor {
    switch (colorTheme) {
      case 'gold':
        return const Color(0xFFF59E0B);
      case 'cyan':
        return const Color(0xFF06B6D4);
      case 'rose':
        return const Color(0xFFF43F5E);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'emerald':
      default:
        return const Color(0xFF10B981);
    }
  }

  // Pace & target estimation calculations
  double get estimatedDailyPace {
    final remainingDays = targetDate != null
        ? targetDate!.difference(DateTime.now()).inDays
        : 30;
    final days = remainingDays <= 0 ? 1 : remainingDays;
    return remainingAmount / days;
  }

  List<String> get unlockedMilestones {
    final list = <String>[];
    final pct = progressPercentage;
    if (pct >= 0.25) list.add('25% Starter');
    if (pct >= 0.50) list.add('50% Halfway Champ');
    if (pct >= 0.75) list.add('75% Homestretch');
    if (pct >= 1.00) list.add('100% Goal Master');
    return list;
  }

  DateTime? get lastSavedAt {
    final completedSegments = segments.where((s) => s.isCompleted && s.completedAt != null).toList();
    if (completedSegments.isEmpty) return null;
    completedSegments.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return completedSegments.first.completedAt;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currencySymbol': currencySymbol,
        'segmentCount': segmentCount,
        'distributionType': distributionType.name,
        'segments': segments.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'targetDate': targetDate?.toIso8601String(),
        'category': category,
        'iconName': iconName,
        'allowCents': allowCents,
        'colorTheme': colorTheme,
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'] as String,
        title: json['title'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currencySymbol: json['currencySymbol'] as String? ?? 'K',
        segmentCount: json['segmentCount'] as int,
        distributionType: DistributionType.values.firstWhere(
          (e) => e.name == json['distributionType'],
          orElse: () => DistributionType.random,
        ),
        segments: (json['segments'] as List)
            .map((s) => SavingsSegment.fromJson(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'] as String)
            : null,
        category: json['category'] as String? ?? 'General',
        iconName: json['iconName'] as String? ?? 'savings',
        allowCents: json['allowCents'] as bool? ?? false,
        colorTheme: json['colorTheme'] as String? ?? 'emerald',
      );
}
