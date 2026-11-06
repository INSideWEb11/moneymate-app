// lib/data/repositories/budget_repository.dart

import '../local/database_helper.dart';
import '../models/budget.dart';
import '../models/income.dart';
import '../models/user_profile.dart';

class BudgetRepository {
  final DatabaseHelper _db;

  BudgetRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  // ======================== Budget Cycles ========================

  Future<BudgetCycle?> getCurrentCycle() async {
    final now = DateTime.now().toIso8601String();
    final rows = await _db.query(
      'budget_cycles',
      where: 'startDate <= ? AND endDate >= ?',
      whereArgs: [now, now],
      orderBy: 'startDate DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BudgetCycle.fromMap(rows.first);
  }

  Future<BudgetCycle?> getById(String id) async {
    final rows = await _db.query(
      'budget_cycles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return BudgetCycle.fromMap(rows.first);
  }

  Future<List<BudgetCycle>> getAll() async {
    final rows = await _db.query('budget_cycles', orderBy: 'startDate DESC');
    return rows.map(BudgetCycle.fromMap).toList();
  }

  Future<void> insertCycle(BudgetCycle cycle) async {
    await _db.insert('budget_cycles', cycle.toMap());
  }

  Future<void> updateCycle(BudgetCycle cycle) async {
    await _db.update('budget_cycles', cycle.toMap(), 'id = ?', [cycle.id]);
  }

  Future<void> deleteCycle(String id) async {
    await _db.delete('budget_cycles', 'id = ?', [id]);
  }

  // ======================== Income Sources ========================

  Future<List<IncomeSource>> getIncomeSources() async {
    final rows = await _db.query(
      'income_sources',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt ASC',
    );
    return rows.map(IncomeSource.fromMap).toList();
  }

  Future<IncomeSource?> getIncomeSourceById(String id) async {
    final rows = await _db.query(
      'income_sources',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return IncomeSource.fromMap(rows.first);
  }

  Future<void> insertIncomeSource(IncomeSource income) async {
    await _db.insert('income_sources', income.toMap());
  }

  Future<void> updateIncomeSource(IncomeSource income) async {
    await _db.update('income_sources', income.toMap(), 'id = ?', [income.id]);
  }

  Future<void> deleteIncomeSource(String id) async {
    await _db.update('income_sources', {'isActive': 0}, 'id = ?', [id]);
  }

  Future<double> getTotalMonthlyIncome() async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM income_sources WHERE isActive = 1',
    );
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  // ======================== User Profile ========================

  Future<UserProfile?> getUserProfile() async {
    final rows = await _db.query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<void> insertUserProfile(UserProfile profile) async {
    await _db.insert('user_profile', profile.toMap());
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final existing = await getUserProfile();
    if (existing == null) {
      await insertUserProfile(profile);
    } else {
      await _db.update('user_profile', profile.toMap(), 'id = ?', [profile.id]);
    }
  }

  // ======================== Category Budgets ========================

  Future<List<CategoryBudget>> getCategoryBudgets(String cycleId) async {
    final rows = await _db.query(
      'category_budgets',
      where: 'budgetCycleId = ?',
      whereArgs: [cycleId],
      orderBy: 'budgeted DESC',
    );
    return rows.map((r) => CategoryBudget.fromMap(r)).toList();
  }

  Future<void> upsertCategoryBudget(
      String cycleId, CategoryBudget budget) async {
    final existing = await _db.query(
      'category_budgets',
      where: 'budgetCycleId = ? AND category = ?',
      whereArgs: [cycleId, budget.category],
    );
    if (existing.isEmpty) {
      await _db.insert('category_budgets', {
        'id': '${cycleId}_${budget.category}',
        'budgetCycleId': cycleId,
        'category': budget.category,
        'budgeted': budget.budgeted,
        'spent': budget.spent,
      });
    } else {
      await _db.update(
        'category_budgets',
        {'budgeted': budget.budgeted, 'spent': budget.spent},
        'budgetCycleId = ? AND category = ?',
        [cycleId, budget.category],
      );
    }
  }

  Future<void> updateCategorySpent(
      String cycleId, String category, double spent) async {
    await _db.update(
      'category_budgets',
      {'spent': spent},
      'budgetCycleId = ? AND category = ?',
      [cycleId, category],
    );
  }
}
