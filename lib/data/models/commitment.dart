// lib/data/models/commitment.dart

import 'package:uuid/uuid.dart';

enum CommitmentType {
  loanEmi,
  healthInsurance,
  bikeInsurance,
  carInsurance,
  otherInsurance,
  rentBill,
  subscription,
  other,
}

extension CommitmentTypeExtension on CommitmentType {
  String get displayName {
    switch (this) {
      case CommitmentType.loanEmi: return 'Loan EMI';
      case CommitmentType.healthInsurance: return 'Health Insurance';
      case CommitmentType.bikeInsurance: return 'Bike Insurance';
      case CommitmentType.carInsurance: return 'Car Insurance';
      case CommitmentType.otherInsurance: return 'Insurance';
      case CommitmentType.rentBill: return 'Rent/Bill';
      case CommitmentType.subscription: return 'Subscription';
      case CommitmentType.other: return 'Other';
    }
  }

  bool get isInsurance {
    return this == CommitmentType.healthInsurance ||
        this == CommitmentType.bikeInsurance ||
        this == CommitmentType.carInsurance ||
        this == CommitmentType.otherInsurance;
  }

  bool get isEmi => this == CommitmentType.loanEmi;

  String get iconName {
    switch (this) {
      case CommitmentType.loanEmi: return 'account_balance';
      case CommitmentType.healthInsurance: return 'health_and_safety';
      case CommitmentType.bikeInsurance: return 'two_wheeler';
      case CommitmentType.carInsurance: return 'directions_car';
      case CommitmentType.otherInsurance: return 'shield';
      case CommitmentType.rentBill: return 'home';
      case CommitmentType.subscription: return 'subscriptions';
      case CommitmentType.other: return 'receipt';
    }
  }

  String get value => toString().split('.').last;

  static CommitmentType fromValue(String value) {
    return CommitmentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CommitmentType.other,
    );
  }
}

class Commitment {
  final String id;
  final String name;
  final String lender; // Lender name or insurer name
  final double amount; // Monthly EMI or premium amount
  final double monthlyReserve; // Amount to reserve per month
  final CommitmentType type;
  final DateTime dueDate; // Next due date
  final DateTime startDate;
  final int? remainingInstallments; // For EMIs
  final bool isPaid; // Paid for current cycle
  final String? policyReference; // For insurance
  final String? vehicleNumber; // For vehicle insurance
  final double? annualPremium; // For insurance (yearly amount)
  final int? savingMonths; // Insurance: months to save before renewal
  final String? loanAccountNumber;
  final String notes;

  Commitment({
    String? id,
    required this.name,
    required this.lender,
    required this.amount,
    required this.monthlyReserve,
    required this.type,
    required this.dueDate,
    required this.startDate,
    this.remainingInstallments,
    this.isPaid = false,
    this.policyReference,
    this.vehicleNumber,
    this.annualPremium,
    this.savingMonths,
    this.loanAccountNumber,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  Commitment copyWith({
    String? id,
    String? name,
    String? lender,
    double? amount,
    double? monthlyReserve,
    CommitmentType? type,
    DateTime? dueDate,
    DateTime? startDate,
    int? remainingInstallments,
    bool? isPaid,
    String? policyReference,
    String? vehicleNumber,
    double? annualPremium,
    int? savingMonths,
    String? loanAccountNumber,
    String? notes,
  }) {
    return Commitment(
      id: id ?? this.id,
      name: name ?? this.name,
      lender: lender ?? this.lender,
      amount: amount ?? this.amount,
      monthlyReserve: monthlyReserve ?? this.monthlyReserve,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      remainingInstallments: remainingInstallments ?? this.remainingInstallments,
      isPaid: isPaid ?? this.isPaid,
      policyReference: policyReference ?? this.policyReference,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      annualPremium: annualPremium ?? this.annualPremium,
      savingMonths: savingMonths ?? this.savingMonths,
      loanAccountNumber: loanAccountNumber ?? this.loanAccountNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lender': lender,
      'amount': amount,
      'monthlyReserve': monthlyReserve,
      'type': type.value,
      'dueDate': dueDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'remainingInstallments': remainingInstallments,
      'isPaid': isPaid ? 1 : 0,
      'policyReference': policyReference,
      'vehicleNumber': vehicleNumber,
      'annualPremium': annualPremium,
      'savingMonths': savingMonths,
      'loanAccountNumber': loanAccountNumber,
      'notes': notes,
    };
  }

  factory Commitment.fromMap(Map<String, dynamic> map) {
    return Commitment(
      id: map['id'] as String,
      name: map['name'] as String,
      lender: map['lender'] as String,
      amount: (map['amount'] as num).toDouble(),
      monthlyReserve: (map['monthlyReserve'] as num).toDouble(),
      type: CommitmentTypeExtension.fromValue(map['type'] as String),
      dueDate: DateTime.parse(map['dueDate'] as String),
      startDate: DateTime.parse(map['startDate'] as String),
      remainingInstallments: map['remainingInstallments'] as int?,
      isPaid: (map['isPaid'] as int? ?? 0) == 1,
      policyReference: map['policyReference'] as String?,
      vehicleNumber: map['vehicleNumber'] as String?,
      annualPremium: (map['annualPremium'] as num?)?.toDouble(),
      savingMonths: map['savingMonths'] as int?,
      loanAccountNumber: map['loanAccountNumber'] as String?,
      notes: map['notes'] as String? ?? '',
    );
  }

  /// Returns true if due within N days
  bool isDueWithin(int days) {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff >= 0 && diff <= days;
  }

  /// Returns true if overdue
  bool get isOverdue {
    return !isPaid && dueDate.isBefore(DateTime.now());
  }

  @override
  String toString() =>
      'Commitment(id: $id, name: $name, type: ${type.displayName}, amount: $amount)';
}
