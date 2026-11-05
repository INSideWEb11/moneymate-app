// lib/presentation/home/widgets/coach_insight_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/budget_engine.dart';

class CoachInsightCard extends StatelessWidget {
  final String insight;
  final BudgetHealthStatus? status;

  const CoachInsightCard({
    super.key,
    required this.insight,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor(status);
    final icon = _getIcon(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cardColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Money Coach',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(BudgetHealthStatus? status) {
    switch (status) {
      case BudgetHealthStatus.safe:
        return AppTheme.successGreen;
      case BudgetHealthStatus.caution:
        return AppTheme.warningAmber;
      case BudgetHealthStatus.overBudget:
        return AppTheme.errorRed;
      default:
        return AppTheme.infoBlue;
    }
  }

  IconData _getIcon(BudgetHealthStatus? status) {
    switch (status) {
      case BudgetHealthStatus.safe:
        return Icons.celebration;
      case BudgetHealthStatus.caution:
        return Icons.trending_flat;
      case BudgetHealthStatus.overBudget:
        return Icons.warning_amber;
      default:
        return Icons.lightbulb_outline;
    }
  }
}
