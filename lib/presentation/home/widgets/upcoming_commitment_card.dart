// lib/presentation/home/widgets/upcoming_commitment_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/commitment.dart';

class UpcomingCommitmentCard extends StatelessWidget {
  final Commitment commitment;

  const UpcomingCommitmentCard({super.key, required this.commitment});

  @override
  Widget build(BuildContext context) {
    final daysLeft = AppDateUtils.daysUntil(commitment.dueDate);
    final isUrgent = daysLeft <= 2;
    final accentColor =
        isUrgent ? AppTheme.errorRed : AppTheme.warningAmber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(commitment.type),
              color: accentColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming: ${commitment.name}',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  commitment.lender,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Amount & countdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(commitment.amount,
                    showDecimal: false),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  daysLeft == 0
                      ? 'Due Today'
                      : daysLeft == 1
                          ? 'Due Tomorrow'
                          : 'In $daysLeft days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(CommitmentType type) {
    switch (type) {
      case CommitmentType.loanEmi:
        return Icons.account_balance;
      case CommitmentType.healthInsurance:
        return Icons.health_and_safety;
      case CommitmentType.bikeInsurance:
        return Icons.two_wheeler;
      case CommitmentType.carInsurance:
        return Icons.directions_car;
      case CommitmentType.otherInsurance:
        return Icons.shield;
      case CommitmentType.rentBill:
        return Icons.home;
      case CommitmentType.subscription:
        return Icons.subscriptions;
      case CommitmentType.other:
        return Icons.receipt;
    }
  }
}
