// lib/data/models/budget.dart

import 'package:uuid/uuid.dart';

class CategoryBudget {
  final String category;
  final double budgeted;
  final double spent;

  CategoryBudget({
    required this.category,
    required this.budgeted,
    required this.spent,
  });

  double get remaining => (budgeted - spent).clamp(0.0, double.infinity);
  double get progressRatio => budgeted > 0 ? (spent / budgeted).clamp(0.0, double.infinity) : 0.0;
  bool get isOverBudget => spent > budgeted;

  CategoryBudget copyWith({double? budgeted, double? spent}) {
    return CategoryBudget(
      category: category,
      budgeted: budgeted ?? this.budgeted,
      spent: spent ?? this.spent,
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category,
        'budgeted': budgeted,
        'spent': spent,
      };

  factory CategoryBudget.fromMap(Map<String, dynamic> map) => CategoryBudget(
        category: map['category'] as String,
        budgeted: (map['budgeted'] as num).toDouble(),
        spent: (map['spent'] as num? ?? 0).toDouble(),
      );
}

class BudgetCycle {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double confirmedIncome;
  final double commitmentReserve;
  final double plannedSavings;
  final double otherReserves;
  final double flexibleBudget;
  final List<CategoryBudget> categoryBudgets;
  final int paydayOfMonth;

  BudgetCycle({
    String? id,
    required this.startDate,
    required this.endDate,
    required this.confirmedIncome,
    required this.commitmentReserve,
    required this.plannedSavings,
    this.otherReserves = 0,
    required this.flexibleBudget,
    required this.paydayOfMonth,
    this.categoryBudgets = const [],
  }) : id = id ?? const Uuid().v4();

  BudgetCycle copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    double? confirmedIncome,
    double? commitmentReserve,
    double? plannedSavings,
    double? otherReserves,
    double? flexibleBudget,
    int? paydayOfMonth,
    List<CategoryBudget>? categoryBudgets,
  }) {
    return BudgetCycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      confirmedIncome: confirmedIncome ?? this.confirmedIncome,
      commitmentReserve: commitmentReserve ?? this.commitmentReserve,
      plannedSavings: plannedSavings ?? this.plannedSavings,
      otherReserves: otherReserves ?? this.otherReserves,
      flexibleBudget: flexibleBudget ?? this.flexibleBudget,
      paydayOfMonth: paydayOfMonth ?? this.paydayOfMonth,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'confirmedIncome': confirmedIncome,
      'commitmentReserve': commitmentReserve,
      'plannedSavings': plannedSavings,
      'otherReserves': otherReserves,
      'flexibleBudget': flexibleBudget,
      'paydayOfMonth': paydayOfMonth,
    };
  }

  factory BudgetCycle.fromMap(Map<String, dynamic> map) {
    return BudgetCycle(
      id: map['id'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      confirmedIncome: (map['confirmedIncome'] as num).toDouble(),
      commitmentReserve: (map['commitmentReserve'] as num).toDouble(),
      plannedSavings: (map['plannedSavings'] as num).toDouble(),
      otherReserves: (map['otherReserves'] as num? ?? 0).toDouble(),
      flexibleBudget: (map['flexibleBudget'] as num).toDouble(),
      paydayOfMonth: map['paydayOfMonth'] as int,
    );
  }
}
