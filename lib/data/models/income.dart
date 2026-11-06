// lib/data/models/income.dart

import 'package:uuid/uuid.dart';

enum IncomeType {
  salary,
  freelance,
  business,
  rental,
  investment,
  pension,
  other,
}

extension IncomeTypeExtension on IncomeType {
  String get displayName {
    switch (this) {
      case IncomeType.salary: return 'Salary';
      case IncomeType.freelance: return 'Freelance';
      case IncomeType.business: return 'Business';
      case IncomeType.rental: return 'Rental Income';
      case IncomeType.investment: return 'Investment Returns';
      case IncomeType.pension: return 'Pension';
      case IncomeType.other: return 'Other';
    }
  }

  String get value => toString().split('.').last;

  static IncomeType fromValue(String value) {
    return IncomeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IncomeType.other,
    );
  }
}

enum IncomeStatus {
  expected, // Not yet received this cycle
  received, // Already received this cycle
}

class IncomeSource {
  final String id;
  final String name;
  final double amount; // Take-home / net amount
  final IncomeType type;
  final int paydayOfMonth; // 1-31, day of month income arrives
  final bool isRegular; // Regular vs irregular
  final IncomeStatus status;
  final String? employerName;
  final String? accountLast4;
  final DateTime createdAt;
  final bool isActive;

  IncomeSource({
    String? id,
    required this.name,
    required this.amount,
    required this.type,
    required this.paydayOfMonth,
    this.isRegular = true,
    this.status = IncomeStatus.expected,
    this.employerName,
    this.accountLast4,
    DateTime? createdAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  IncomeSource copyWith({
    String? id,
    String? name,
    double? amount,
    IncomeType? type,
    int? paydayOfMonth,
    bool? isRegular,
    IncomeStatus? status,
    String? employerName,
    String? accountLast4,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      paydayOfMonth: paydayOfMonth ?? this.paydayOfMonth,
      isRegular: isRegular ?? this.isRegular,
      status: status ?? this.status,
      employerName: employerName ?? this.employerName,
      accountLast4: accountLast4 ?? this.accountLast4,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type.value,
      'paydayOfMonth': paydayOfMonth,
      'isRegular': isRegular ? 1 : 0,
      'status': status == IncomeStatus.received ? 'received' : 'expected',
      'employerName': employerName,
      'accountLast4': accountLast4,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory IncomeSource.fromMap(Map<String, dynamic> map) {
    return IncomeSource(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: IncomeTypeExtension.fromValue(map['type'] as String),
      paydayOfMonth: map['paydayOfMonth'] as int,
      isRegular: (map['isRegular'] as int? ?? 1) == 1,
      status: map['status'] == 'received'
          ? IncomeStatus.received
          : IncomeStatus.expected,
      employerName: map['employerName'] as String?,
      accountLast4: map['accountLast4'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  @override
  String toString() =>
      'IncomeSource(id: $id, name: $name, amount: $amount, type: ${type.displayName})';
}
