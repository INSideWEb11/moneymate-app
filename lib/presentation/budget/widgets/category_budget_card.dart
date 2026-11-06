// lib/presentation/budget/widgets/category_budget_card.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/budget.dart';
import 'budget_progress_bar.dart';

class CategoryBudgetCard extends StatelessWidget {
  final CategoryBudget budget;
  final VoidCallback? onEdit;

  const CategoryBudgetCard({
    super.key,
    required this.budget,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = budget.progressRatio;
    final statusColor = AppTheme.getStatusColor(ratio);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(budget.category),
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${CurrencyFormatter.format(budget.spent, showDecimal: false)} of ${CurrencyFormatter.format(budget.budgeted, showDecimal: false)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    budget.isOverBudget
                        ? '${CurrencyFormatter.format(budget.spent - budget.budgeted, showDecimal: false)} over'
                        : '${CurrencyFormatter.format(budget.remaining, showDecimal: false)} left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '${(ratio * 100).clamp(0, 999).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                        ),
                  ),
                ],
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          BudgetProgressBar(value: ratio),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    const iconMap = <String, IconData>{
      'Food & Dining': Icons.restaurant,
      'Groceries': Icons.local_grocery_store,
      'Transport': Icons.directions_bus,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Health & Medical': Icons.local_hospital,
      'Education': Icons.school,
      'Utilities': Icons.power,
      'Fuel': Icons.local_gas_station,
      'Personal Care': Icons.spa,
      'Travel': Icons.flight,
      'Electronics': Icons.devices,
      'Home & Maintenance': Icons.home_repair_service,
      'Gifts & Donations': Icons.card_giftcard,
      'Investment': Icons.trending_up,
    };
    return iconMap[category] ?? Icons.more_horiz;
  }
}
