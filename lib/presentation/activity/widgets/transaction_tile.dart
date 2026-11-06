// lib/presentation/activity/widgets/transaction_tile.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = !transaction.type.isDebit;
    final amountColor =
        isCredit ? AppTheme.successGreen : AppTheme.errorRed;
    final amountPrefix = isCredit ? '+' : '-';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildIcon(context),
      title: Row(
        children: [
          Expanded(
            child: Text(
              transaction.merchantName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!transaction.isReviewed)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.warningAmber,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Row(
            children: [
              _buildCategoryChip(context, transaction.category),
              const SizedBox(width: 6),
              _buildSourceBadge(context, transaction.source),
              if (showDate) ...[
                const SizedBox(width: 6),
                Text(
                  AppDateUtils.formatShort(transaction.date),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Text(
        '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final iconName = AppConstants.categoryIcons[transaction.category] ??
        AppConstants.categoryIcons['Other']!;
    final iconData = _getMaterialIcon(iconName);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSourceBadge(BuildContext context, TransactionSource source) {
    if (source == TransactionSource.manual) return const SizedBox.shrink();

    Color color;
    String label;

    switch (source) {
      case TransactionSource.sms:
        color = AppTheme.infoBlue;
        label = 'SMS';
        break;
      case TransactionSource.csv:
        color = AppTheme.warningAmber;
        label = 'CSV';
        break;
      case TransactionSource.accountAggregator:
        color = AppTheme.primaryGreen;
        label = 'AA';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String name) {
    const iconMap = <String, IconData>{
      'restaurant': Icons.restaurant,
      'local_grocery_store': Icons.local_grocery_store,
      'directions_bus': Icons.directions_bus,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'power': Icons.power,
      'local_gas_station': Icons.local_gas_station,
      'spa': Icons.spa,
      'flight': Icons.flight,
      'devices': Icons.devices,
      'home_repair_service': Icons.home_repair_service,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'more_horiz': Icons.more_horiz,
      'account_balance_wallet': Icons.account_balance_wallet,
      'work': Icons.work,
      'business': Icons.business,
      'bar_chart': Icons.bar_chart,
      'house': Icons.house,
      'star': Icons.star,
      'redeem': Icons.redeem,
      'replay': Icons.replay,
      'attach_money': Icons.attach_money,
    };
    return iconMap[name] ?? Icons.receipt;
  }
}
