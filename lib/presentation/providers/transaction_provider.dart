// lib/presentation/providers/transaction_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/duplicate_detector.dart';
import '../../domain/transaction_classifier.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repo;
  final DuplicateDetector _duplicateDetector;
  final TransactionClassifier _classifier;

  List<Transaction> _transactions = [];
  List<Transaction> _reviewQueue = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionType? _typeFilter;

  TransactionProvider({
    TransactionRepository? repo,
    DuplicateDetector? duplicateDetector,
    TransactionClassifier? classifier,
  })  : _repo = repo ?? TransactionRepository(),
        _duplicateDetector = duplicateDetector ?? DuplicateDetector(),
        _classifier = classifier ?? TransactionClassifier();

  List<Transaction> get transactions => _applyFilters(_transactions);
  List<Transaction> get allTransactions => _transactions;
  List<Transaction> get reviewQueue => _reviewQueue;
  bool get isLoading => _isLoading;
  int get reviewCount => _reviewQueue.length;
  String get searchQuery => _searchQuery;
  TransactionType? get typeFilter => _typeFilter;

  List<Transaction> _applyFilters(List<Transaction> txns) {
    var filtered = txns;
    if (_typeFilter != null) {
      filtered = filtered.where((t) => t.type == _typeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((t) =>
              t.merchantName.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q) ||
              t.notes.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _repo.getAll();
      _reviewQueue = await _repo.getForReview();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return _repo.getByDateRange(start, end);
  }

  Future<void> addTransaction(Transaction transaction) async {
    // Duplicate check
    final dupResult = _duplicateDetector.detect(
      candidate: transaction,
      existing: _transactions,
    );

    if (dupResult.isDuplicate && dupResult.confidence >= 0.9) {
      final duplicate = transaction.copyWith(isDuplicate: true);
      await _repo.insert(duplicate);
    } else {
      await _repo.insert(transaction);
      _transactions.insert(0, transaction);
      if (!transaction.isReviewed) {
        _reviewQueue.insert(0, transaction);
      }
    }
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repo.update(transaction);
    final idx = _transactions.indexWhere((t) => t.id == transaction.id);
    if (idx >= 0) _transactions[idx] = transaction;
    _reviewQueue.removeWhere((t) => t.id == transaction.id);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.delete(id);
    _transactions.removeWhere((t) => t.id == id);
    _reviewQueue.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> markAsReviewed(String id) async {
    await _repo.markAsReviewed(id);
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _transactions[idx] = _transactions[idx].copyWith(isReviewed: true);
    }
    _reviewQueue.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> updateCategory(String id, String category) async {
    await _repo.updateCategory(id, category);
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _transactions[idx] =
          _transactions[idx].copyWith(category: category, isReviewed: true);
    }
    _reviewQueue.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> markAsDuplicate(String id) async {
    await _repo.markAsDuplicate(id);
    _transactions.removeWhere((t) => t.id == id);
    _reviewQueue.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Transaction> getRecent(int count) {
    return _transactions.take(count).toList();
  }

  Future<Map<String, double>> getSpendingByCategory(
      DateTime start, DateTime end) async {
    return _repo.getSpendingByCategory(start, end);
  }

  /// Total variable spend in a date range (excludes EMI/Insurance/Savings)
  double getTotalVariableSpend(DateTime start, DateTime end) {
    return _transactions
        .where((t) =>
            !t.isDuplicate &&
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1))) &&
            t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Group transactions by date for display
  Map<String, List<Transaction>> getGroupedByDate(List<Transaction> txns) {
    final grouped = <String, List<Transaction>>{};
    for (final tx in txns) {
      final key = _dateKey(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  String _dateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) return 'Today';
    if (txDate == yesterday) return 'Yesterday';
    return '${date.day} ${_month(date.month)} ${date.year}';
  }

  String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}
