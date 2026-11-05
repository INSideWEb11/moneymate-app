// lib/core/utils/currency_formatter.dart

import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _inrNoDecimalFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _inrCompactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
  );

  /// Formats amount in Indian number system: ₹1,00,000.00
  static String format(double amount, {bool showDecimal = true}) {
    if (showDecimal) {
      return _inrFormat.format(amount);
    } else {
      return _inrNoDecimalFormat.format(amount);
    }
  }

  /// Returns compact format: ₹1L, ₹2.5Cr
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      // Crore
      final cr = amount / 10000000;
      return '₹${_formatDecimal(cr)}Cr';
    } else if (amount >= 100000) {
      // Lakh
      final l = amount / 100000;
      return '₹${_formatDecimal(l)}L';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      return '₹${_formatDecimal(k)}K';
    }
    return format(amount, showDecimal: false);
  }

  static String _formatDecimal(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  /// Formats amount without currency symbol in Indian number system
  static String formatNumber(double amount, {bool showDecimal = true}) {
    final formatted = format(amount, showDecimal: showDecimal);
    return formatted.replaceFirst('₹', '').trim();
  }

  /// Formats amount as signed (+ for income, - for expense)
  static String formatSigned(double amount, {bool isExpense = true}) {
    final formatted = format(amount.abs(), showDecimal: true);
    return isExpense ? '-$formatted' : '+$formatted';
  }

  /// Parses Indian formatted currency string to double
  static double? parse(String input) {
    try {
      final cleaned = input
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Returns description in words (e.g., "1 lakh 50 thousand")
  static String toWords(double amount) {
    if (amount >= 10000000) {
      final crores = (amount / 10000000).toStringAsFixed(2);
      return '₹$crores crore';
    } else if (amount >= 100000) {
      final lakhs = (amount / 100000).toStringAsFixed(2);
      return '₹$lakhs lakh';
    } else if (amount >= 1000) {
      final thousands = (amount / 1000).toStringAsFixed(1);
      return '₹$thousands thousand';
    }
    return format(amount);
  }

  /// Formats a percentage
  static String formatPercent(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
}
