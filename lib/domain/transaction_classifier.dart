// lib/domain/transaction_classifier.dart

import '../data/models/transaction.dart';
import '../core/constants/app_constants.dart';

class ClassificationResult {
  final String category;
  final TransactionType type;
  final double confidence;
  final bool needsReview;

  ClassificationResult({
    required this.category,
    required this.type,
    required this.confidence,
    required this.needsReview,
  });
}

class TransactionClassifier {
  // Merchant patterns → (category, TransactionType)
  static const Map<String, Map<String, dynamic>> _merchantPatterns = {
    // Food & Dining
    'swiggy': {'category': 'Food & Dining', 'type': 'expense'},
    'zomato': {'category': 'Food & Dining', 'type': 'expense'},
    'mcdonald': {'category': 'Food & Dining', 'type': 'expense'},
    'dominos': {'category': 'Food & Dining', 'type': 'expense'},
    'pizza hut': {'category': 'Food & Dining', 'type': 'expense'},
    'kfc': {'category': 'Food & Dining', 'type': 'expense'},
    'cafe coffee': {'category': 'Food & Dining', 'type': 'expense'},
    'starbucks': {'category': 'Food & Dining', 'type': 'expense'},
    'blinkit': {'category': 'Groceries', 'type': 'expense'},
    'dunzo': {'category': 'Groceries', 'type': 'expense'},
    'bigbasket': {'category': 'Groceries', 'type': 'expense'},
    'grofers': {'category': 'Groceries', 'type': 'expense'},
    'zepto': {'category': 'Groceries', 'type': 'expense'},
    'instamart': {'category': 'Groceries', 'type': 'expense'},
    'dmart': {'category': 'Groceries', 'type': 'expense'},

    // Transport
    'uber': {'category': 'Transport', 'type': 'expense'},
    'ola': {'category': 'Transport', 'type': 'expense'},
    'rapido': {'category': 'Transport', 'type': 'expense'},
    'metro': {'category': 'Transport', 'type': 'expense'},
    'irctc': {'category': 'Travel', 'type': 'expense'},
    'makemytrip': {'category': 'Travel', 'type': 'expense'},
    'goibibo': {'category': 'Travel', 'type': 'expense'},
    'cleartrip': {'category': 'Travel', 'type': 'expense'},

    // Shopping
    'amazon': {'category': 'Shopping', 'type': 'expense'},
    'flipkart': {'category': 'Shopping', 'type': 'expense'},
    'myntra': {'category': 'Shopping', 'type': 'expense'},
    'meesho': {'category': 'Shopping', 'type': 'expense'},
    'ajio': {'category': 'Shopping', 'type': 'expense'},
    'nykaa': {'category': 'Personal Care', 'type': 'expense'},

    // Health
    'apollo': {'category': 'Health & Medical', 'type': 'expense'},
    'netmeds': {'category': 'Health & Medical', 'type': 'expense'},
    '1mg': {'category': 'Health & Medical', 'type': 'expense'},
    'pharmeasy': {'category': 'Health & Medical', 'type': 'expense'},
    'practo': {'category': 'Health & Medical', 'type': 'expense'},

    // Utilities
    'bescom': {'category': 'Utilities', 'type': 'expense'},
    'bsnl': {'category': 'Utilities', 'type': 'expense'},
    'airtel': {'category': 'Utilities', 'type': 'expense'},
    'jio': {'category': 'Utilities', 'type': 'expense'},
    'vi ': {'category': 'Utilities', 'type': 'expense'},
    'tata sky': {'category': 'Utilities', 'type': 'expense'},
    'dish tv': {'category': 'Utilities', 'type': 'expense'},

    // Entertainment
    'netflix': {'category': 'Entertainment', 'type': 'expense'},
    'spotify': {'category': 'Entertainment', 'type': 'expense'},
    'hotstar': {'category': 'Entertainment', 'type': 'expense'},
    'prime video': {'category': 'Entertainment', 'type': 'expense'},
    'zee5': {'category': 'Entertainment', 'type': 'expense'},
    'pvr': {'category': 'Entertainment', 'type': 'expense'},
    'inox': {'category': 'Entertainment', 'type': 'expense'},
    'bookmyshow': {'category': 'Entertainment', 'type': 'expense'},

    // Fuel
    'indian oil': {'category': 'Fuel', 'type': 'expense'},
    'hp petrol': {'category': 'Fuel', 'type': 'expense'},
    'bharat petroleum': {'category': 'Fuel', 'type': 'expense'},
    'petrol': {'category': 'Fuel', 'type': 'expense'},

    // Education
    'byju': {'category': 'Education', 'type': 'expense'},
    'unacademy': {'category': 'Education', 'type': 'expense'},
    'coursera': {'category': 'Education', 'type': 'expense'},
    'udemy': {'category': 'Education', 'type': 'expense'},

    // Financial (transfers, etc.)
    'atm': {'category': 'Other', 'type': 'cashWithdrawal'},
    'cash withdrawal': {'category': 'Other', 'type': 'cashWithdrawal'},
    'neft': {'category': 'Other', 'type': 'ownTransfer'},
    'imps': {'category': 'Other', 'type': 'ownTransfer'},
    'rtgs': {'category': 'Other', 'type': 'ownTransfer'},
    'lic': {'category': 'Other', 'type': 'insurancePayment'},
    'hdfc life': {'category': 'Other', 'type': 'insurancePayment'},
    'star health': {'category': 'Other', 'type': 'insurancePayment'},
  };

  // Keyword patterns in merchant/description
  static const Map<String, String> _keywordPatterns = {
    'salary': 'income',
    'payroll': 'income',
    'credited by employer': 'income',
    'emi': 'emiPayment',
    'loan emi': 'emiPayment',
    'insurance premium': 'insurancePayment',
    'premium paid': 'insurancePayment',
    'mutual fund': 'savingsContribution',
    'sip': 'savingsContribution',
    'recurring deposit': 'savingsContribution',
    'rent': 'expense',
    'maintenance': 'expense',
    'electricity': 'expense',
    'water bill': 'expense',
    'gas bill': 'expense',
    'refund': 'refund',
    'cashback': 'refund',
    'reversal': 'refund',
    'reimbursement': 'reimbursement',
    'claim settled': 'reimbursement',
  };

  /// Classify a transaction based on merchant name and amount
  ClassificationResult classify({
    required String merchantName,
    required double amount,
    required bool isCredit, // credit = money coming in
    String? description,
  }) {
    final merchantLower = merchantName.toLowerCase();
    final descLower = (description ?? '').toLowerCase();
    final combined = '$merchantLower $descLower';

    // 1. Check merchant patterns (high confidence)
    for (final entry in _merchantPatterns.entries) {
      if (combined.contains(entry.key)) {
        final typeStr = entry.value['type'] as String;
        final category = entry.value['category'] as String;
        final txType = _parseType(typeStr, isCredit);
        return ClassificationResult(
          category: category,
          type: txType,
          confidence: 0.90,
          needsReview: false,
        );
      }
    }

    // 2. Check keyword patterns
    for (final entry in _keywordPatterns.entries) {
      if (combined.contains(entry.key)) {
        final typeStr = entry.value;
        final txType = _parseType(typeStr, isCredit);
        final category = _categoryForType(txType, isCredit);
        return ClassificationResult(
          category: category,
          type: txType,
          confidence: 0.75,
          needsReview: txType == TransactionType.income,
        );
      }
    }

    // 3. Amount-based heuristics for credits
    if (isCredit) {
      // Large round-number credits are likely salary/transfers
      if (amount >= 5000 && amount == amount.roundToDouble()) {
        // Do NOT auto-classify as income — needs review
        return ClassificationResult(
          category: 'Other Income',
          type: TransactionType.income,
          confidence: AppConstants.lowConfidence,
          needsReview: true, // Always review credit classifications
        );
      }
      // Small credit likely refund
      if (amount < 500) {
        return ClassificationResult(
          category: 'Other',
          type: TransactionType.refund,
          confidence: AppConstants.mediumConfidence,
          needsReview: true,
        );
      }
      // Unknown credit — needs review
      return ClassificationResult(
        category: 'Other Income',
        type: TransactionType.income,
        confidence: AppConstants.lowConfidence,
        needsReview: true,
      );
    }

    // 4. Unknown debit — classify as expense, needs review
    return ClassificationResult(
      category: 'Other',
      type: TransactionType.expense,
      confidence: AppConstants.lowConfidence,
      needsReview: true,
    );
  }

  static TransactionType _parseType(String typeStr, bool isCredit) {
    if (typeStr == 'income' && isCredit) return TransactionType.income;
    switch (typeStr) {
      case 'expense':
        return TransactionType.expense;
      case 'cashWithdrawal':
        return TransactionType.cashWithdrawal;
      case 'ownTransfer':
        return TransactionType.ownTransfer;
      case 'emiPayment':
        return TransactionType.emiPayment;
      case 'insurancePayment':
        return TransactionType.insurancePayment;
      case 'savingsContribution':
        return TransactionType.savingsContribution;
      case 'refund':
        return TransactionType.refund;
      case 'reimbursement':
        return TransactionType.reimbursement;
      case 'income':
        return isCredit ? TransactionType.income : TransactionType.expense;
      default:
        return isCredit ? TransactionType.income : TransactionType.expense;
    }
  }

  static String _categoryForType(TransactionType type, bool isCredit) {
    switch (type) {
      case TransactionType.income:
        return 'Salary';
      case TransactionType.refund:
      case TransactionType.reimbursement:
        return 'Refund';
      case TransactionType.emiPayment:
        return 'Other';
      case TransactionType.insurancePayment:
        return 'Other';
      case TransactionType.savingsContribution:
        return 'Investment';
      case TransactionType.cashWithdrawal:
        return 'Other';
      case TransactionType.ownTransfer:
        return 'Other';
      default:
        return 'Other';
    }
  }

  /// Learn from user corrections to improve future classification
  Map<String, String> learnFromCorrection({
    required String merchantName,
    required String correctedCategory,
    required TransactionType correctedType,
  }) {
    return {
      'merchantPattern': merchantName.toLowerCase().trim(),
      'category': correctedCategory,
      'transactionType': correctedType.value,
    };
  }
}
