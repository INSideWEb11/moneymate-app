// lib/presentation/home/widgets/savings_progress_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/goal.dart';

class SavingsProgressCard extends StatelessWidget {
  final List<Goal> goals;
  final double totalSaved;

  const SavingsProgressCard({
    super.key,
    required this.goals,
    required this.totalSaved,
  });

  @override
  Widget build(BuildContext context) {
    final totalTarget =
        goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final overallRatio =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    final primaryGoal = goals.isNotEmpty ? goals.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Savings Goals',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                '${goals.length} active',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (primaryGoal != null) ...[
            Row(
              children: [
                // Circular progress
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: primaryGoal.progressRatio,
                        strokeWidth: 6,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${primaryGoal.progressPercent.toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryGoal.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CurrencyFormatter.formatCompact(primaryGoal.currentAmount)} of ${CurrencyFormatter.formatCompact(primaryGoal.targetAmount)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+ ${CurrencyFormatter.format(primaryGoal.monthlyContribution, showDecimal: false)}/month',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (goals.length > 1) ...[
              const SizedBox(height: 12),
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: 1,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Saved',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    CurrencyFormatter.formatCompact(totalSaved),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active goals. Add one to track savings!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
