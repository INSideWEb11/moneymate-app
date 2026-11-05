// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart';

class AppDateUtils {
  static final _displayFormat = DateFormat('dd MMM yyyy');
  static final _shortFormat = DateFormat('dd MMM');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _monthYearFormat = DateFormat('MMM yyyy');
  static final _fullFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Returns current time in IST (UTC+5:30)
  static DateTime nowIST() {
    final utc = DateTime.now().toUtc();
    return utc.add(const Duration(hours: 5, minutes: 30));
  }

  /// Returns today's date (IST) with time zeroed
  static DateTime todayIST() {
    final now = nowIST();
    return DateTime(now.year, now.month, now.day);
  }

  /// Gets the start date of the current budget cycle
  static DateTime getBudgetCycleStart({required int paydayOfMonth}) {
    final today = todayIST();
    if (today.day >= paydayOfMonth) {
      return DateTime(today.year, today.month, paydayOfMonth);
    } else {
      final prevMonth = today.month == 1 ? 12 : today.month - 1;
      final prevYear = today.month == 1 ? today.year - 1 : today.year;
      return DateTime(prevYear, prevMonth, paydayOfMonth);
    }
  }

  /// Gets the end date of the current budget cycle
  static DateTime getBudgetCycleEnd({required int paydayOfMonth}) {
    final start = getBudgetCycleStart(paydayOfMonth: paydayOfMonth);
    final nextMonth = start.month == 12 ? 1 : start.month + 1;
    final nextYear = start.month == 12 ? start.year + 1 : start.year;
    return DateTime(nextYear, nextMonth, paydayOfMonth)
        .subtract(const Duration(days: 1));
  }

  /// Returns number of days remaining in budget cycle
  static int daysRemainingInCycle({required int paydayOfMonth}) {
    final end = getBudgetCycleEnd(paydayOfMonth: paydayOfMonth);
    final today = todayIST();
    final diff = end.difference(today).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  /// Returns total days in current budget cycle
  static int totalDaysInCycle({required int paydayOfMonth}) {
    final start = getBudgetCycleStart(paydayOfMonth: paydayOfMonth);
    final end = getBudgetCycleEnd(paydayOfMonth: paydayOfMonth);
    return end.difference(start).inDays + 1;
  }

  /// Days until a specific date from today
  static int daysUntil(DateTime target) {
    final today = todayIST();
    final targetDate = DateTime(target.year, target.month, target.day);
    final diff = targetDate.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Days overdue (negative means overdue)
  static int daysOverdue(DateTime dueDate) {
    final today = todayIST();
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today.difference(dueDateOnly).inDays;
  }

  /// Checks if date is in current month
  static bool isCurrentMonth(DateTime date) {
    final now = todayIST();
    return date.year == now.year && date.month == now.month;
  }

  /// Checks if date is today
  static bool isToday(DateTime date) {
    final today = todayIST();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Checks if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = todayIST().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Gets greeting based on hour
  static String getGreeting() {
    final hour = nowIST().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Formats date for display
  static String formatDisplay(DateTime date) => _displayFormat.format(date);
  static String formatShort(DateTime date) => _shortFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String formatFull(DateTime date) => _fullFormat.format(date);

  /// Groups transactions by date label
  static String getDateGroupLabel(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return formatDisplay(date);
  }

  /// Returns next occurrence of a day-of-month date
  static DateTime nextOccurrenceOfDay(int dayOfMonth) {
    final today = todayIST();
    if (today.day <= dayOfMonth) {
      return DateTime(today.year, today.month, dayOfMonth);
    } else {
      final nextMonth = today.month == 12 ? 1 : today.month + 1;
      final nextYear = today.month == 12 ? today.year + 1 : today.year;
      return DateTime(nextYear, nextMonth, dayOfMonth);
    }
  }

  /// Returns list of months between two dates
  static List<DateTime> monthsBetween(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month);
    while (!current.isAfter(DateTime(end.year, end.month))) {
      months.add(current);
      current = DateTime(
        current.month == 12 ? current.year + 1 : current.year,
        current.month == 12 ? 1 : current.month + 1,
      );
    }
    return months;
  }

  /// Insurance saving months (months until renewal)
  static int monthsUntilRenewal(DateTime renewalDate) {
    final today = todayIST();
    final months = (renewalDate.year - today.year) * 12 +
        (renewalDate.month - today.month);
    return months < 1 ? 1 : months;
  }
}
