// lib/data/repositories/commitment_repository.dart

import '../local/database_helper.dart';
import '../models/commitment.dart';

class CommitmentRepository {
  final DatabaseHelper _db;

  CommitmentRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper();

  static const String _table = 'commitments';

  Future<List<Commitment>> getAll() async {
    final rows = await _db.query(_table, orderBy: 'dueDate ASC');
    return rows.map(Commitment.fromMap).toList();
  }

  Future<Commitment?> getById(String id) async {
    final rows = await _db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Commitment.fromMap(rows.first);
  }

  Future<List<Commitment>> getByType(CommitmentType type) async {
    final rows = await _db.query(
      _table,
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'dueDate ASC',
    );
    return rows.map(Commitment.fromMap).toList();
  }

  Future<List<Commitment>> getEmis() async {
    final rows = await _db.query(
      _table,
      where: 'type = ?',
      whereArgs: [CommitmentType.loanEmi.value],
      orderBy: 'dueDate ASC',
    );
    return rows.map(Commitment.fromMap).toList();
  }

  Future<List<Commitment>> getInsurances() async {
    final rows = await _db.query(
      _table,
      where: "type IN ('healthInsurance','bikeInsurance','carInsurance','otherInsurance')",
      orderBy: 'dueDate ASC',
    );
    return rows.map(Commitment.fromMap).toList();
  }

  /// Returns commitments due within [days] days
  Future<List<Commitment>> getUpcoming({int days = 7}) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    final rows = await _db.query(
      _table,
      where: 'dueDate <= ? AND isPaid = ?',
      whereArgs: [future.toIso8601String(), 0],
      orderBy: 'dueDate ASC',
    );
    return rows.map(Commitment.fromMap).toList();
  }

  Future<Commitment?> getNextDue() async {
    final rows = await _db.query(
      _table,
      where: 'isPaid = ?',
      whereArgs: [0],
      orderBy: 'dueDate ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Commitment.fromMap(rows.first);
  }

  Future<void> insert(Commitment commitment) async {
    await _db.insert(_table, commitment.toMap());
  }

  Future<void> update(Commitment commitment) async {
    await _db.update(_table, commitment.toMap(), 'id = ?', [commitment.id]);
  }

  Future<void> delete(String id) async {
    await _db.delete(_table, 'id = ?', [id]);
  }

  Future<void> markPaid(String id) async {
    final commitment = await getById(id);
    if (commitment == null) return;

    await _db.update(_table, {'isPaid': 1}, 'id = ?', [id]);

    // For EMIs, decrease remaining installments
    if (commitment.type == CommitmentType.loanEmi &&
        commitment.remainingInstallments != null) {
      final newRemaining = commitment.remainingInstallments! - 1;
      if (newRemaining <= 0) {
        // EMI completed
        await _db.delete(_table, 'id = ?', [id]);
      } else {
        // Advance due date by 1 month
        final nextDue = DateTime(
          commitment.dueDate.year,
          commitment.dueDate.month + 1,
          commitment.dueDate.day,
        );
        await _db.update(
          _table,
          {
            'dueDate': nextDue.toIso8601String(),
            'remainingInstallments': newRemaining,
            'isPaid': 0,
          },
          'id = ?',
          [id],
        );
      }
    }
  }

  Future<void> markUnpaid(String id) async {
    await _db.update(_table, {'isPaid': 0}, 'id = ?', [id]);
  }

  Future<double> getTotalMonthlyReserve() async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(monthlyReserve), 0) as total FROM $_table',
    );
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  Future<void> resetMonthlyPaidStatus() async {
    // Reset paid status at start of new cycle (for non-EMI commitments)
    await _db.rawQuery(
      "UPDATE $_table SET isPaid = 0 WHERE type NOT IN ('loanEmi')",
    );
  }
}
