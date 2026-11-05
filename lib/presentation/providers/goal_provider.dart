// lib/presentation/providers/goal_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repo;

  List<Goal> _goals = [];
  bool _isLoading = false;

  GoalProvider({GoalRepository? repo}) : _repo = repo ?? GoalRepository();

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  List<Goal> get activeGoals =>
      _goals.where((g) => g.isActive && !g.isCompleted).toList();

  List<Goal> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  double get totalMonthlyContribution =>
      activeGoals.fold(0.0, (sum, g) => sum + g.monthlyContribution);

  double get totalSaved =>
      _goals.where((g) => g.isActive).fold(0.0, (sum, g) => sum + g.currentAmount);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _goals = await _repo.getAll(activeOnly: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Goal goal) async {
    await _repo.insert(goal);
    _goals.add(goal);
    notifyListeners();
  }

  Future<void> update(Goal goal) async {
    await _repo.update(goal);
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) _goals[idx] = goal;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx >= 0) _goals[idx] = _goals[idx].copyWith(isActive: false);
    notifyListeners();
  }

  Future<void> contribute(String id, double amount) async {
    await _repo.contribute(id, amount);
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      final goal = _goals[idx];
      final newAmount = goal.currentAmount + amount;
      _goals[idx] = goal.copyWith(
        currentAmount: newAmount,
        isCompleted: newAmount >= goal.targetAmount,
      );
    }
    notifyListeners();
  }
}
