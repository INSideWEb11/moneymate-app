// lib/data/repositories/transaction_repository.dart

import '../local/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final DatabaseHelper _db;

  TransactionRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper();

  static const String _table = 'transactions';

  Future<List<Transaction>> getAll({bool excludeDuplicates = true}) async {
    final rows = await _db.query(
      _table,
      where: excludeDuplicates ? 'isDuplicate = ?' : null,
      whereArgs: excludeDuplicates ? [0] : null,
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getByDateRange(
    DateTime start,
    DateTime end, {
    bool excludeDuplicates = true,
  }) async {
    final rows = await _db.query(
      _table,
      where: excludeDuplicates
          ? 'date >= ? AND date <= ? AND isDuplicate = ?'
          : 'date >= ? AND date <= ?',
      whereArgs: excludeDuplicates
          ? [start.toIso8601String(), end.toIso8601String(), 0]
          : [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getByCategory(String category) async {
    final rows = await _db.query(
      _table,
      where: 'category = ? AND isDuplicate = ?',
      whereArgs: [category, 0],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getByType(TransactionType type) async {
    final rows = await _db.query(
      _table,
      where: 'type = ? AND isDuplicate = ?',
      whereArgs: [type.value, 0],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  /// Transactions needing user review
  Future<List<Transaction>> getForReview() async {
    final rows = await _db.query(
      _table,
      where: 'isReviewed = ? AND isDuplicate = ?',
      whereArgs: [0, 0],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<Transaction?> getById(String id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Transaction.fromMap(rows.first);
  }

  Future<void> insert(Transaction transaction) async {
    await _db.insert(_table, transaction.toMap());
  }

  Future<void> insertAll(List<Transaction> transactions) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final t in transactions) {
      batch.insert(_table, t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> update(Transaction transaction) async {
    await _db.update(
      _table,
      transaction.toMap(),
      'id = ?',
      [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(_table, 'id = ?', [id]);
  }

  Future<void> markAsDuplicate(String id) async {
    await _db.update(_table, {'isDuplicate': 1}, 'id = ?', [id]);
  }

  Future<void> markAsReviewed(String id) async {
    await _db.update(_table, {'isReviewed': 1}, 'id = ?', [id]);
  }

  Future<void> updateCategory(String id, String category) async {
    await _db.update(_table, {'category': category, 'isReviewed': 1}, 'id = ?', [id]);
  }

  Future<double> getTotalExpenseForPeriod(DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0) as total FROM $_table 
         WHERE date >= ? AND date <= ? AND isDuplicate = 0
         AND type IN ('expense','cashWithdrawal','creditCardPurchase','emiPayment','insurancePayment')''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  Future<double> getTotalIncomeForPeriod(DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0) as total FROM $_table 
         WHERE date >= ? AND date <= ? AND isDuplicate = 0
         AND type IN ('income','reimbursement','refund')''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  Future<Map<String, double>> getSpendingByCategory(
      DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      '''SELECT category, COALESCE(SUM(amount), 0) as total FROM $_table 
         WHERE date >= ? AND date <= ? AND isDuplicate = 0
         AND type = 'expense'
         GROUP BY category''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return {
      for (final row in result)
        row['category'] as String: (row['total'] as num).toDouble()
    };
  }

  Future<List<Transaction>> getRecent(int count) async {
    final rows = await _db.query(
      _table,
      where: 'isDuplicate = ?',
      whereArgs: [0],
      orderBy: 'date DESC',
      limit: count,
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<int> getReviewCount() async {
    return _db.count(_table, where: 'isReviewed = ? AND isDuplicate = ?', whereArgs: [0, 0]);
  }

  Future<void> deleteAll() async {
    await _db.delete(_table, '1 = ?', [1]);
  }
}
