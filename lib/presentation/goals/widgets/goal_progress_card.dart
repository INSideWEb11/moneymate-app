// lib/presentation/goals/widgets/goal_progress_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/goal.dart';

class GoalProgressCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onContribute;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.onContribute,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressRatio;
    final isOnTrack = goal.isOnTrack;
    final daysToTarget = AppDateUtils.daysUntil(goal.targetDate);
    final progressColor =
        progress >= 1.0 ? AppTheme.successGreen : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: goal.isCompleted
            ? Border.all(color: AppTheme.successGreen.withOpacity(0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(goal.category),
                  color: progressColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      goal.isCompleted
                          ? '🎉 Goal completed!'
                          : isOnTrack
                              ? '✅ On track'
                              : '⚠️ Behind schedule',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: goal.isCompleted
                                ? AppTheme.successGreen
                                : isOnTrack
                                    ? AppTheme.successGreen
                                    : AppTheme.warningAmber,
                          ),
                    ),
                  ],
                ),
              ),
              // Circular progress
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor:
                          progressColor.withOpacity(0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                    Text(
                      '${(progress * 100).clamp(0, 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Amount progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: progressColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saved',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(
                        CurrencyFormatter.formatCompact(goal.currentAmount),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Target',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(
                        CurrencyFormatter.formatCompact(goal.targetAmount),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Target Date',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(
                        daysToTarget <= 0
                            ? 'Passed'
                            : '${AppDateUtils.formatShort(goal.targetDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '+ ${CurrencyFormatter.format(goal.monthlyContribution, showDecimal: false)}/month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (!goal.isCompleted)
                ElevatedButton(
                  onPressed: onContribute,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 36),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Contribute'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.emergency:
        return Icons.health_and_safety;
      case GoalCategory.vacation:
        return Icons.beach_access;
      case GoalCategory.gadget:
        return Icons.devices;
      case GoalCategory.vehicle:
        return Icons.directions_car;
      case GoalCategory.home:
        return Icons.home;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.wedding:
        return Icons.favorite;
      case GoalCategory.investment:
        return Icons.trending_up;
      case GoalCategory.other:
        return Icons.star;
    }
  }
}
