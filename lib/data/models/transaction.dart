// lib/data/models/transaction.dart

import 'package:uuid/uuid.dart';

enum TransactionType {
  expense,
  income,
  ownTransfer,
  cashWithdrawal,
  refund,
  reimbursement,
  creditCardPurchase,
  creditCardSettlement,
  savingsContribution,
  emiPayment,
  insurancePayment,
}

enum TransactionSource {
  manual,
  sms,
  csv,
  accountAggregator,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense: return 'Expense';
      case TransactionType.income: return 'Income';
      case TransactionType.ownTransfer: return 'Own Transfer';
      case TransactionType.cashWithdrawal: return 'Cash Withdrawal';
      case TransactionType.refund: return 'Refund';
      case TransactionType.reimbursement: return 'Reimbursement';
      case TransactionType.creditCardPurchase: return 'Credit Card Purchase';
      case TransactionType.creditCardSettlement: return 'Credit Card Settlement';
      case TransactionType.savingsContribution: return 'Savings';
      case TransactionType.emiPayment: return 'EMI Payment';
      case TransactionType.insurancePayment: return 'Insurance Payment';
    }
  }

  bool get isDebit {
    switch (this) {
      case TransactionType.expense:
      case TransactionType.cashWithdrawal:
      case TransactionType.creditCardPurchase:
      case TransactionType.creditCardSettlement:
      case TransactionType.savingsContribution:
      case TransactionType.emiPayment:
      case TransactionType.insurancePayment:
      case TransactionType.ownTransfer:
        return true;
      case TransactionType.income:
      case TransactionType.refund:
      case TransactionType.reimbursement:
        return false;
    }
  }

  String get value => toString().split('.').last;

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.expense,
    );
  }
}

extension TransactionSourceExtension on TransactionSource {
  String get displayName {
    switch (this) {
      case TransactionSource.manual: return 'Manual';
      case TransactionSource.sms: return 'SMS';
      case TransactionSource.csv: return 'CSV';
      case TransactionSource.accountAggregator: return 'Account Aggregator';
    }
  }

  String get value => toString().split('.').last;

  static TransactionSource fromValue(String value) {
    return TransactionSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionSource.manual,
    );
  }
}

class Transaction {
  final String id;
  final String merchantName;
  final String category;
  final String notes;
  final String sourceRef;
  final double amount;
  final TransactionType type;
  final TransactionSource source;
  final DateTime date;
  final bool isReviewed;
  final bool isDuplicate;
  final double confidenceScore;
  final String? linkedCommitmentId;
  final String? accountLast4;

  Transaction({
    String? id,
    required this.merchantName,
    required this.category,
    this.notes = '',
    this.sourceRef = '',
    required this.amount,
    required this.type,
    this.source = TransactionSource.manual,
    required this.date,
    this.isReviewed = true,
    this.isDuplicate = false,
    this.confidenceScore = 1.0,
    this.linkedCommitmentId,
    this.accountLast4,
  }) : id = id ?? const Uuid().v4();

  Transaction copyWith({
    String? id,
    String? merchantName,
    String? category,
    String? notes,
    String? sourceRef,
    double? amount,
    TransactionType? type,
    TransactionSource? source,
    DateTime? date,
    bool? isReviewed,
    bool? isDuplicate,
    double? confidenceScore,
    String? linkedCommitmentId,
    String? accountLast4,
  }) {
    return Transaction(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      sourceRef: sourceRef ?? this.sourceRef,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      source: source ?? this.source,
      date: date ?? this.date,
      isReviewed: isReviewed ?? this.isReviewed,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      linkedCommitmentId: linkedCommitmentId ?? this.linkedCommitmentId,
      accountLast4: accountLast4 ?? this.accountLast4,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantName': merchantName,
      'category': category,
      'notes': notes,
      'sourceRef': sourceRef,
      'amount': amount,
      'type': type.value,
      'source': source.value,
      'date': date.toIso8601String(),
      'isReviewed': isReviewed ? 1 : 0,
      'isDuplicate': isDuplicate ? 1 : 0,
      'confidenceScore': confidenceScore,
      'linkedCommitmentId': linkedCommitmentId,
      'accountLast4': accountLast4,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      merchantName: map['merchantName'] as String,
      category: map['category'] as String,
      notes: map['notes'] as String? ?? '',
      sourceRef: map['sourceRef'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: TransactionTypeExtension.fromValue(map['type'] as String),
      source: TransactionSourceExtension.fromValue(map['source'] as String),
      date: DateTime.parse(map['date'] as String),
      isReviewed: (map['isReviewed'] as int) == 1,
      isDuplicate: (map['isDuplicate'] as int) == 1,
      confidenceScore: (map['confidenceScore'] as num? ?? 1.0).toDouble(),
      linkedCommitmentId: map['linkedCommitmentId'] as String?,
      accountLast4: map['accountLast4'] as String?,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, merchant: $merchantName, amount: $amount, type: ${type.displayName})';
}
