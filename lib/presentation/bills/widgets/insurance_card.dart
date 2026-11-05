// lib/presentation/bills/widgets/insurance_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/commitment.dart';

class InsuranceCard extends StatelessWidget {
  final Commitment insurance;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InsuranceCard({
    super.key,
    required this.insurance,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final renewalMonths = AppDateUtils.monthsUntilRenewal(insurance.dueDate);
    final isUrgent = renewalMonths <= 2;
    final accentColor =
        isUrgent ? AppTheme.warningAmber : AppTheme.infoBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
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
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _typeIcon(insurance.type),
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insurance.name,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      '${insurance.lender} • ${insurance.type.displayName}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: 'Annual Premium',
                  value: CurrencyFormatter.format(
                      insurance.annualPremium ?? insurance.amount,
                      showDecimal: false),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: 'Monthly Reserve',
                  value: CurrencyFormatter.format(insurance.monthlyReserve,
                      showDecimal: false),
                  valueColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: 'Renewal',
                  value: AppDateUtils.formatDisplay(insurance.dueDate),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: 'Months Away',
                  value: renewalMonths <= 0
                      ? 'Due Now!'
                      : '$renewalMonths months',
                  valueColor: isUrgent ? AppTheme.warningAmber : null,
                ),
              ),
            ],
          ),
          if (insurance.policyReference != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.policy_outlined,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  'Policy: ${insurance.policyReference}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
          if (insurance.vehicleNumber != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.directions_car,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  'Vehicle: ${insurance.vehicleNumber}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
          if (isUrgent) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppTheme.warningAmber, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Renewal upcoming — ₹${insurance.monthlyReserve.toStringAsFixed(0)}/month being reserved',
                    style: const TextStyle(
                      color: AppTheme.warningAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required String label, required String value, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  IconData _typeIcon(CommitmentType type) {
    switch (type) {
      case CommitmentType.healthInsurance:
        return Icons.health_and_safety;
      case CommitmentType.bikeInsurance:
        return Icons.two_wheeler;
      case CommitmentType.carInsurance:
        return Icons.directions_car;
      default:
        return Icons.shield;
    }
  }
}
