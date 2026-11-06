// lib/domain/budget_engine.dart

import '../data/models/commitment.dart';
import '../data/models/income.dart';
import '../data/models/goal.dart';
import '../core/utils/date_utils.dart';

enum BudgetHealthStatus {
  safe,    // <80% spent
  caution, // 80-100% spent
  overBudget, // >100% spent
}

class BudgetCalculationResult {
  final double confirmedIncome;
  final double commitmentReserve;
  final double plannedSavings;
  final double otherReserves;
  final double flexibleBudget;
  final double totalExpenses;
  final double remainingFlexibleBudget;
  final double dailySafeToSpend;
  final int daysLeft;
  final BudgetHealthStatus status;
  final double spendingRatio;

  BudgetCalculationResult({
    required this.confirmedIncome,
    required this.commitmentReserve,
    required this.plannedSavings,
    required this.otherReserves,
    required this.flexibleBudget,
    required this.totalExpenses,
    required this.remainingFlexibleBudget,
    required this.dailySafeToSpend,
    required this.daysLeft,
    required this.status,
    required this.spendingRatio,
  });
}

class BudgetEngine {
  /// Insurance sinking fund: annualPremium / savingMonths = monthlyReserve
  static double calculateInsuranceMonthlyReserve({
    required double annualPremium,
    required int savingMonths,
  }) {
    if (savingMonths <= 0) return annualPremium;
    return annualPremium / savingMonths;
  }

  /// Flexible budget = confirmedIncome - commitmentReserve - plannedSavings - otherReserves
  static double calculateFlexibleBudget({
    required double confirmedIncome,
    required double commitmentReserve,
    required double plannedSavings,
    double otherReserves = 0,
  }) {
    final flexible =
        confirmedIncome - commitmentReserve - plannedSavings - otherReserves;
    return flexible < 0 ? 0 : flexible;
  }

  /// Remaining flexible budget = max(0, flexibleBudget - eligibleVariableSpend)
  static double calculateRemainingFlexibleBudget({
    required double flexibleBudget,
    required double totalVariableSpend,
  }) {
    return (flexibleBudget - totalVariableSpend).clamp(0.0, double.infinity);
  }

  /// Daily safe to spend = max(0, remainingFlexibleBudget) / daysLeft
  static double calculateDailySafeToSpend({
    required double remainingFlexibleBudget,
    required int daysLeft,
  }) {
    if (daysLeft <= 0) return 0;
    return (remainingFlexibleBudget / daysLeft).clamp(0.0, double.infinity);
  }

  /// Total commitment reserves (sum of monthly reserves for all commitments)
  static double totalCommitmentReserve(List<Commitment> commitments) {
    return commitments.fold(0.0, (sum, c) => sum + c.monthlyReserve);
  }

  /// Total planned savings from goals
  static double totalPlannedSavings(List<Goal> goals) {
    return goals
        .where((g) => g.isActive && !g.isCompleted)
        .fold(0.0, (sum, g) => sum + g.monthlyContribution);
  }

  /// Total confirmed income from active income sources
  static double totalConfirmedIncome(List<IncomeSource> sources) {
    return sources
        .where((s) => s.isActive)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  /// Full budget calculation — the core engine
  static BudgetCalculationResult calculate({
    required List<IncomeSource> incomeSources,
    required List<Commitment> commitments,
    required List<Goal> goals,
    required double totalVariableSpend,
    required int paydayOfMonth,
    double otherReserves = 0,
  }) {
    final confirmedIncome = totalConfirmedIncome(incomeSources);
    final commitmentReserve = totalCommitmentReserve(commitments);
    final plannedSavings = totalPlannedSavings(goals);

    final flexibleBudget = calculateFlexibleBudget(
      confirmedIncome: confirmedIncome,
      commitmentReserve: commitmentReserve,
      plannedSavings: plannedSavings,
      otherReserves: otherReserves,
    );

    final remainingFlexibleBudget = calculateRemainingFlexibleBudget(
      flexibleBudget: flexibleBudget,
      totalVariableSpend: totalVariableSpend,
    );

    final daysLeft =
        AppDateUtils.daysRemainingInCycle(paydayOfMonth: paydayOfMonth);

    final dailySafeToSpend = calculateDailySafeToSpend(
      remainingFlexibleBudget: remainingFlexibleBudget,
      daysLeft: daysLeft,
    );

    final spendingRatio =
        flexibleBudget > 0 ? (totalVariableSpend / flexibleBudget) : 0.0;

    BudgetHealthStatus status;
    if (spendingRatio <= 0.8) {
      status = BudgetHealthStatus.safe;
    } else if (spendingRatio <= 1.0) {
      status = BudgetHealthStatus.caution;
    } else {
      status = BudgetHealthStatus.overBudget;
    }

    return BudgetCalculationResult(
      confirmedIncome: confirmedIncome,
      commitmentReserve: commitmentReserve,
      plannedSavings: plannedSavings,
      otherReserves: otherReserves,
      flexibleBudget: flexibleBudget,
      totalExpenses: totalVariableSpend,
      remainingFlexibleBudget: remainingFlexibleBudget,
      dailySafeToSpend: dailySafeToSpend,
      daysLeft: daysLeft,
      status: status,
      spendingRatio: spendingRatio,
    );
  }

  /// Generates contextual coach insight based on budget state
  static String generateCoachInsight(BudgetCalculationResult result) {
    final ratio = result.spendingRatio;
    final daysLeft = result.daysLeft;
    final daily = result.dailySafeToSpend;

    if (result.flexibleBudget <= 0) {
      return "⚠️ Your commitments and savings goals use your entire income. Consider reviewing your budget plan.";
    }

    if (ratio <= 0.3 && daysLeft > 15) {
      return "🎉 Excellent! You've spent only ${(ratio * 100).toInt()}% of your flexible budget. You're right on track!";
    } else if (ratio <= 0.5) {
      return "✅ You're managing well! ₹${daily.toStringAsFixed(0)}/day keeps you comfortably on budget.";
    } else if (ratio <= 0.7) {
      return "📊 Halfway through your budget. Keep spending to ₹${daily.toStringAsFixed(0)}/day to finish strong.";
    } else if (ratio <= 0.85) {
      return "⚡ You've used ${(ratio * 100).toInt()}% of your flexible budget. Watch your discretionary spending.";
    } else if (ratio <= 1.0) {
      return "⚠️ Caution! You're close to your budget limit. Only ₹${daily.toStringAsFixed(0)}/day left for $daysLeft days.";
    } else {
      final overage = result.totalExpenses - result.flexibleBudget;
      return "🔴 You're ₹${overage.toStringAsFixed(0)} over your flexible budget. Time to cut back!";
    }
  }

  /// Returns color status string
  static String getStatusLabel(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.safe:
        return 'On Track';
      case BudgetHealthStatus.caution:
        return 'Caution';
      case BudgetHealthStatus.overBudget:
        return 'Over Budget';
    }
  }

  /// Projected end-of-month balance
  static double projectEndOfMonthBalance({
    required double remainingFlexibleBudget,
    required double dailySafeToSpend,
    required int daysLeft,
    required double avgDailySpend,
  }) {
    final projectedSpend = avgDailySpend * daysLeft;
    return remainingFlexibleBudget - projectedSpend;
  }
}
