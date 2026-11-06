// lib/domain/duplicate_detector.dart

import '../data/models/transaction.dart';
import '../core/constants/app_constants.dart';

class DuplicateDetectionResult {
  final bool isDuplicate;
  final String? duplicateId;
  final double confidence;
  final String reason;

  DuplicateDetectionResult({
    required this.isDuplicate,
    this.duplicateId,
    required this.confidence,
    required this.reason,
  });
}

class DuplicateDetector {
  /// Layered duplicate detection
  DuplicateDetectionResult detect({
    required Transaction candidate,
    required List<Transaction> existing,
  }) {
    // Layer 1: Exact sourceRef match (highest confidence)
    if (candidate.sourceRef.isNotEmpty) {
      for (final tx in existing) {
        if (tx.sourceRef == candidate.sourceRef && tx.id != candidate.id) {
          return DuplicateDetectionResult(
            isDuplicate: true,
            duplicateId: tx.id,
            confidence: 1.0,
            reason: 'Exact reference ID match',
          );
        }
      }
    }

    // Layer 2: Fuzzy match — amount + direction + date window + merchant
    final candidateDate = candidate.date;
    final windowStart = candidateDate.subtract(
      Duration(hours: AppConstants.duplicateWindowHours),
    );
    final windowEnd = candidateDate.add(
      Duration(hours: AppConstants.duplicateWindowHours),
    );

    final candidateMerchant = _normalizeMerchant(candidate.merchantName);
    final candidateIsDebit = candidate.type.isDebit;

    for (final tx in existing) {
      if (tx.id == candidate.id) continue;

      // Same direction (debit/credit)
      if (tx.type.isDebit != candidateIsDebit) continue;

      // Within date window
      if (tx.date.isBefore(windowStart) || tx.date.isAfter(windowEnd)) continue;

      // Amount within tolerance
      final amountDiff = (tx.amount - candidate.amount).abs();
      if (amountDiff > AppConstants.duplicateAmountTolerance * candidate.amount &&
          amountDiff > 1.0) continue;

      // Merchant similarity
      final txMerchant = _normalizeMerchant(tx.merchantName);
      final merchantSimilarity = _merchantSimilarity(candidateMerchant, txMerchant);

      // Account last4 match (if both have it)
      bool accountMatches = true;
      if (candidate.accountLast4 != null &&
          tx.accountLast4 != null &&
          candidate.accountLast4 != tx.accountLast4) {
        accountMatches = false;
      }

      if (merchantSimilarity >= 0.8 && accountMatches) {
        return DuplicateDetectionResult(
          isDuplicate: true,
          duplicateId: tx.id,
          confidence: merchantSimilarity * (amountDiff < 1.0 ? 1.0 : 0.9),
          reason:
              'Amount + date window + merchant match (${(merchantSimilarity * 100).toInt()}% similar)',
        );
      }

      // Even without merchant match, exact amount + exact date is suspicious
      if (amountDiff < 0.01 &&
          tx.date.year == candidateDate.year &&
          tx.date.month == candidateDate.month &&
          tx.date.day == candidateDate.day &&
          accountMatches) {
        return DuplicateDetectionResult(
          isDuplicate: true,
          duplicateId: tx.id,
          confidence: 0.70,
          reason: 'Same amount and date — possible duplicate',
        );
      }
    }

    return DuplicateDetectionResult(
      isDuplicate: false,
      confidence: 0.0,
      reason: 'No duplicate found',
    );
  }

  String _normalizeMerchant(String merchant) {
    return merchant
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double _merchantSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    // Check if one contains the other
    if (a.contains(b) || b.contains(a)) return 0.9;

    // Token-based similarity
    final aWords = a.split(' ').toSet();
    final bWords = b.split(' ').toSet();
    final common = aWords.intersection(bWords).length;
    final total = aWords.union(bWords).length;
    if (total == 0) return 0.0;
    return common / total;
  }

  /// Batch duplicate detection — returns IDs of suspected duplicates
  List<String> detectBatchDuplicates(List<Transaction> transactions) {
    final duplicateIds = <String>[];
    final processed = <Transaction>[];

    for (final tx in transactions) {
      final result = detect(candidate: tx, existing: processed);
      if (result.isDuplicate && result.confidence >= 0.8) {
        duplicateIds.add(tx.id);
      } else {
        processed.add(tx);
      }
    }

    return duplicateIds;
  }
}
