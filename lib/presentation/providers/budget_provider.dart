// lib/presentation/providers/budget_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/budget.dart';
import '../../data/models/income.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/budget_engine.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repo;

  List<IncomeSource> _incomeSources = [];
  BudgetCycle? _currentCycle;
  BudgetCalculationResult? _calculation;
  List<CategoryBudget> _categoryBudgets = [];
  bool _isLoading = false;

  BudgetProvider({BudgetRepository? repo})
      : _repo = repo ?? BudgetRepository();

  List<IncomeSource> get incomeSources => _incomeSources;
  BudgetCycle? get currentCycle => _currentCycle;
  BudgetCalculationResult? get calculation => _calculation;
  List<CategoryBudget> get categoryBudgets => _categoryBudgets;
  bool get isLoading => _isLoading;

  double get totalIncome =>
      _incomeSources.where((s) => s.isActive).fold(0.0, (s, i) => s + i.amount);

  Future<void> load({
    required List commitments,
    required List goals,
    required double totalVariableSpend,
    required int paydayOfMonth,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _incomeSources = await _repo.getIncomeSources();
      _currentCycle = await _repo.getCurrentCycle();
      if (_currentCycle != null) {
        _categoryBudgets = await _repo.getCategoryBudgets(_currentCycle!.id);
      }
      _recalculate(
        commitments: commitments,
        goals: goals,
        totalVariableSpend: totalVariableSpend,
        paydayOfMonth: paydayOfMonth,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void recalculate({
    required List commitments,
    required List goals,
    required double totalVariableSpend,
    required int paydayOfMonth,
  }) {
    _recalculate(
      commitments: commitments,
      goals: goals,
      totalVariableSpend: totalVariableSpend,
      paydayOfMonth: paydayOfMonth,
    );
    notifyListeners();
  }

  void _recalculate({
    required List commitments,
    required List goals,
    required double totalVariableSpend,
    required int paydayOfMonth,
  }) {
    _calculation = BudgetEngine.calculate(
      incomeSources: _incomeSources.cast(),
      commitments: commitments.cast(),
      goals: goals.cast(),
      totalVariableSpend: totalVariableSpend,
      paydayOfMonth: paydayOfMonth,
    );
  }

  Future<void> addIncomeSource(IncomeSource income) async {
    await _repo.insertIncomeSource(income);
    _incomeSources.add(income);
    notifyListeners();
  }

  Future<void> updateIncomeSource(IncomeSource income) async {
    await _repo.updateIncomeSource(income);
    final idx = _incomeSources.indexWhere((s) => s.id == income.id);
    if (idx >= 0) _incomeSources[idx] = income;
    notifyListeners();
  }

  Future<void> removeIncomeSource(String id) async {
    await _repo.deleteIncomeSource(id);
    _incomeSources.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  String get coachInsight {
    if (_calculation == null) return '';
    return BudgetEngine.generateCoachInsight(_calculation!);
  }
}
