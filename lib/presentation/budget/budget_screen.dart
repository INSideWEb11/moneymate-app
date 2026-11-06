// lib/presentation/budget/budget_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/commitment_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_profile_provider.dart';
import 'widgets/category_budget_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final commitmentProvider = context.watch<CommitmentProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final profileProvider = context.watch<UserProfileProvider>();

    final calc = budgetProvider.calculation;
    final incomeSources = budgetProvider.incomeSources;

    // Build category budgets from actual spending
    final spendingData = <String, double>{};
    for (final tx in txProvider.allTransactions) {
      if (tx.type.isDebit && !tx.isDuplicate) {
        spendingData[tx.category] =
            (spendingData[tx.category] ?? 0) + tx.amount;
      }
    }

    // Create category budgets dynamically
    final categoryBudgets = spendingData.entries
        .where((e) => e.value > 0)
        .map((e) => CategoryBudget(
              category: e.key,
              budgeted: (calc?.flexibleBudget ?? 0) *
                  _categoryAllocation(e.key),
              spent: e.value,
            ))
        .toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: calc == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // Income summary card
                _buildSummaryCard(
                  context,
                  title: 'Income',
                  amount: calc.confirmedIncome,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppTheme.successGreen,
                  subtitle: '${incomeSources.length} source(s)',
                ),
                const SizedBox(height: 8),

                // Budget breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget Breakdown',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 16),
                      _buildBudgetRow(
                        context,
                        'Confirmed Income',
                        calc.confirmedIncome,
                        AppTheme.successGreen,
                        isPositive: true,
                      ),
                      _buildBudgetRow(
                        context,
                        'Commitment Reserves',
                        -calc.commitmentReserve,
                        AppTheme.errorRed,
                      ),
                      _buildBudgetRow(
                        context,
                        'Planned Savings',
                        -calc.plannedSavings,
                        AppTheme.warningAmber,
                      ),
                      const Divider(height: 20),
                      _buildBudgetRow(
                        context,
                        'Flexible Budget',
                        calc.flexibleBudget,
                        Theme.of(context).colorScheme.primary,
                        isBold: true,
                      ),
                      _buildBudgetRow(
                        context,
                        'Spent This Cycle',
                        -calc.totalExpenses,
                        AppTheme.errorRed,
                      ),
                      const Divider(height: 20),
                      _buildBudgetRow(
                        context,
                        'Remaining',
                        calc.remainingFlexibleBudget,
                        AppTheme.getStatusColor(calc.spendingRatio),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Chart
                if (categoryBudgets.isNotEmpty) ...[
                  Text('Spending by Category',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  _buildPieChart(context, categoryBudgets),
                  const SizedBox(height: 12),
                ],

                // Category breakdown
                if (categoryBudgets.isNotEmpty) ...[
                  Text('Category Details',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...categoryBudgets
                      .take(8)
                      .map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CategoryBudgetCard(budget: b),
                          )),
                ],
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6))),
                Text(CurrencyFormatter.format(amount, showDecimal: false),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(
    BuildContext context,
    String label,
    double amount,
    Color color, {
    bool isBold = false,
    bool isPositive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
          Text(
            isPositive
                ? CurrencyFormatter.format(amount, showDecimal: false)
                : amount < 0
                    ? '- ${CurrencyFormatter.format(-amount, showDecimal: false)}'
                    : CurrencyFormatter.format(amount, showDecimal: false),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
      BuildContext context, List<CategoryBudget> categories) {
    final total = categories.fold(0.0, (s, c) => s + c.spent);
    if (total == 0) return const SizedBox.shrink();

    final colors = [
      AppTheme.primaryGreen,
      AppTheme.accentGold,
      AppTheme.errorRed,
      AppTheme.infoBlue,
      AppTheme.warningAmber,
      const Color(0xFF7B1FA2),
      const Color(0xFF00695C),
      const Color(0xFFE65100),
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: categories.take(6).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            return PieChartSectionData(
              value: cat.spent,
              title: '${(cat.spent / total * 100).toStringAsFixed(0)}%',
              color: colors[i % colors.length],
              radius: 70,
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  double _categoryAllocation(String category) {
    const allocations = <String, double>{
      'Food & Dining': 0.20,
      'Groceries': 0.15,
      'Transport': 0.10,
      'Shopping': 0.10,
      'Entertainment': 0.08,
      'Health & Medical': 0.07,
      'Utilities': 0.08,
      'Fuel': 0.07,
    };
    return allocations[category] ?? 0.05;
  }
}
