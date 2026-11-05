// lib/data/models/goal.dart

import 'package:uuid/uuid.dart';

enum GoalCategory {
  emergency,
  vacation,
  gadget,
  vehicle,
  home,
  education,
  wedding,
  investment,
  other,
}

extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.emergency: return 'Emergency Fund';
      case GoalCategory.vacation: return 'Vacation';
      case GoalCategory.gadget: return 'Gadget/Electronics';
      case GoalCategory.vehicle: return 'Vehicle';
      case GoalCategory.home: return 'Home/Property';
      case GoalCategory.education: return 'Education';
      case GoalCategory.wedding: return 'Wedding';
      case GoalCategory.investment: return 'Investment';
      case GoalCategory.other: return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case GoalCategory.emergency: return 'health_and_safety';
      case GoalCategory.vacation: return 'beach_access';
      case GoalCategory.gadget: return 'devices';
      case GoalCategory.vehicle: return 'directions_car';
      case GoalCategory.home: return 'home';
      case GoalCategory.education: return 'school';
      case GoalCategory.wedding: return 'favorite';
      case GoalCategory.investment: return 'trending_up';
      case GoalCategory.other: return 'star';
    }
  }

  String get value => toString().split('.').last;

  static GoalCategory fromValue(String value) {
    return GoalCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GoalCategory.other,
    );
  }
}

class Goal {
  final String id;
  final String name;
  final GoalCategory category;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final DateTime targetDate;
  final DateTime createdAt;
  final String notes;
  final bool isCompleted;
  final bool isActive;

  Goal({
    String? id,
    required this.name,
    required this.category,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.monthlyContribution,
    required this.targetDate,
    DateTime? createdAt,
    this.notes = '',
    this.isCompleted = false,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Goal copyWith({
    String? id,
    String? name,
    GoalCategory? category,
    double? targetAmount,
    double? currentAmount,
    double? monthlyContribution,
    DateTime? targetDate,
    DateTime? createdAt,
    String? notes,
    bool? isCompleted,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.value,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyContribution': monthlyContribution,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      category: GoalCategoryExtension.fromValue(map['category'] as String),
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num? ?? 0).toDouble(),
      monthlyContribution: (map['monthlyContribution'] as num).toDouble(),
      targetDate: DateTime.parse(map['targetDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      notes: map['notes'] as String? ?? '',
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  double get progressRatio =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get progressPercent => progressRatio * 100;

  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  /// Projected completion date based on monthly contribution
  DateTime get projectedCompletionDate {
    if (monthlyContribution <= 0) return targetDate;
    final monthsLeft = (remaining / monthlyContribution).ceil();
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthsLeft, now.day);
  }

  bool get isOnTrack {
    final projected = projectedCompletionDate;
    return !projected.isAfter(targetDate);
  }

  @override
  String toString() =>
      'Goal(id: $id, name: $name, target: $targetAmount, current: $currentAmount)';
}
