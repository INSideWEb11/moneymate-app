// lib/presentation/home/widgets/safe_to_spend_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/budget_engine.dart';

class SafeToSpendCard extends StatelessWidget {
  final BudgetCalculationResult calculation;

  const SafeToSpendCard({super.key, required this.calculation});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(calculation.status);
    final statusLabel = BudgetEngine.getStatusLabel(calculation.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            statusColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe to Spend Today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Amount
          Text(
            CurrencyFormatter.format(calculation.dailySafeToSpend),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                ),
          ),

          const SizedBox(height: 4),

          Text(
            'per day',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),

          const SizedBox(height: 12),

          // Bottom stats
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  context,
                  label: 'Remaining',
                  value: CurrencyFormatter.formatCompact(
                      calculation.remainingFlexibleBudget),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStat(
                  context,
                  label: 'Days Left',
                  value: '${calculation.daysLeft} days',
                  align: TextAlign.center,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStat(
                  context,
                  label: 'Spent',
                  value: CurrencyFormatter.formatCompact(
                      calculation.totalExpenses),
                  align: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          _buildProgressBar(calculation.spendingRatio),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context,
      {required String label,
      required String value,
      TextAlign align = TextAlign.left}) {
    return Column(
      crossAxisAlignment: align == TextAlign.left
          ? CrossAxisAlignment.start
          : align == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          textAlign: align,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          textAlign: align,
        ),
      ],
    );
  }

  Widget _buildProgressBar(double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(ratio * 100).clamp(0, 100).toStringAsFixed(1)}% of flexible budget used',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _statusColor(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.safe:
        return AppTheme.primaryGreen;
      case BudgetHealthStatus.caution:
        return AppTheme.warningAmber;
      case BudgetHealthStatus.overBudget:
        return AppTheme.errorRed;
    }
  }
}
