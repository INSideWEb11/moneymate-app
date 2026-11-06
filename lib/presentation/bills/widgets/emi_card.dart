// lib/presentation/bills/widgets/emi_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/commitment.dart';

class EmiCard extends StatelessWidget {
  final Commitment emi;
  final VoidCallback onMarkPaid;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EmiCard({
    super.key,
    required this.emi,
    required this.onMarkPaid,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = AppDateUtils.daysUntil(emi.dueDate);
    final isOverdue = emi.isOverdue;
    final isPaid = emi.isPaid;

    Color statusColor;
    if (isPaid) {
      statusColor = AppTheme.successGreen;
    } else if (isOverdue) {
      statusColor = AppTheme.errorRed;
    } else if (daysLeft <= 3) {
      statusColor = AppTheme.warningAmber;
    } else {
      statusColor = AppTheme.infoBlue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? AppTheme.successGreen.withOpacity(0.3)
              : statusColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance,
                    color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emi.name,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(emi.lender,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(emi.amount, showDecimal: false),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text('/month',
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoChip(
                context,
                icon: Icons.calendar_today,
                label: isPaid
                    ? 'Paid ✓'
                    : isOverdue
                        ? 'Overdue!'
                        : daysLeft == 0
                            ? 'Due Today'
                            : 'Due in $daysLeft days',
                color: statusColor,
              ),
              const SizedBox(width: 8),
              if (emi.remainingInstallments != null)
                _buildInfoChip(
                  context,
                  icon: Icons.repeat,
                  label: '${emi.remainingInstallments} left',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              const Spacer(),
              GestureDetector(
                onTap: onMarkPaid,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppTheme.successGreen.withOpacity(0.1)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPaid
                          ? AppTheme.successGreen
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Text(
                    isPaid ? 'Paid ✓' : 'Mark Paid',
                    style: TextStyle(
                      color: isPaid
                          ? AppTheme.successGreen
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (emi.loanAccountNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              'Account: ${emi.loanAccountNumber}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context,
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
