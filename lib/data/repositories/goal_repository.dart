// lib/data/repositories/goal_repository.dart

import '../local/database_helper.dart';
import '../models/goal.dart';

class GoalRepository {
  final DatabaseHelper _db;

  GoalRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  static const String _table = 'goals';

  Future<List<Goal>> getAll({bool activeOnly = true}) async {
    final rows = await _db.query(
      _table,
      where: activeOnly ? 'isActive = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'createdAt ASC',
    );
    return rows.map(Goal.fromMap).toList();
  }

  Future<Goal?> getById(String id) async {
    final rows = await _db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Goal.fromMap(rows.first);
  }

  Future<void> insert(Goal goal) async {
    await _db.insert(_table, goal.toMap());
  }

  Future<void> update(Goal goal) async {
    await _db.update(_table, goal.toMap(), 'id = ?', [goal.id]);
  }

  Future<void> delete(String id) async {
    // Soft delete
    await _db.update(_table, {'isActive': 0}, 'id = ?', [id]);
  }

  Future<void> contribute(String id, double amount) async {
    final goal = await getById(id);
    if (goal == null) return;
    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount;
    await _db.update(
      _table,
      {
        'currentAmount': newAmount,
        'isCompleted': isCompleted ? 1 : 0,
      },
      'id = ?',
      [id],
    );
  }

  Future<void> markComplete(String id) async {
    await _db.update(_table, {'isCompleted': 1}, 'id = ?', [id]);
  }

  Future<Map<String, double>> getProgress(String id) async {
    final goal = await getById(id);
    if (goal == null) return {'progress': 0.0, 'remaining': 0.0};
    return {
      'progress': goal.progressRatio,
      'remaining': goal.remaining,
    };
  }

  Future<double> getTotalMonthlyContributions() async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(monthlyContribution), 0) as total FROM $_table WHERE isActive = 1 AND isCompleted = 0',
    );
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  Future<double> getTotalSaved() async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(currentAmount), 0) as total FROM $_table WHERE isActive = 1',
    );
    return (result.first['total'] as num? ?? 0).toDouble();
  }
}
