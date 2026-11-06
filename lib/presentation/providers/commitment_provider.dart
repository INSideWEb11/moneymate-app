// lib/presentation/providers/commitment_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/commitment.dart';
import '../../data/repositories/commitment_repository.dart';

class CommitmentProvider extends ChangeNotifier {
  final CommitmentRepository _repo;

  List<Commitment> _commitments = [];
  bool _isLoading = false;

  CommitmentProvider({CommitmentRepository? repo})
      : _repo = repo ?? CommitmentRepository();

  List<Commitment> get commitments => _commitments;
  bool get isLoading => _isLoading;

  List<Commitment> get emis =>
      _commitments.where((c) => c.type == CommitmentType.loanEmi).toList();

  List<Commitment> get insurances => _commitments
      .where((c) => c.type.isInsurance)
      .toList();

  List<Commitment> get bills => _commitments
      .where((c) =>
          c.type == CommitmentType.rentBill ||
          c.type == CommitmentType.subscription ||
          c.type == CommitmentType.other)
      .toList();

  List<Commitment> get upcoming => _commitments
      .where((c) => !c.isPaid && c.isDueWithin(7))
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  Commitment? get nextDue => upcoming.isNotEmpty ? upcoming.first : null;

  double get totalMonthlyReserve =>
      _commitments.fold(0.0, (sum, c) => sum + c.monthlyReserve);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _commitments = await _repo.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Commitment commitment) async {
    await _repo.insert(commitment);
    _commitments.add(commitment);
    _commitments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> update(Commitment commitment) async {
    await _repo.update(commitment);
    final idx = _commitments.indexWhere((c) => c.id == commitment.id);
    if (idx >= 0) _commitments[idx] = commitment;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _commitments.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> markPaid(String id) async {
    await _repo.markPaid(id);
    await load(); // Reload to get updated state (EMI due date advances)
  }

  Future<void> markUnpaid(String id) async {
    await _repo.markUnpaid(id);
    final idx = _commitments.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      _commitments[idx] = _commitments[idx].copyWith(isPaid: false);
    }
    notifyListeners();
  }
}
