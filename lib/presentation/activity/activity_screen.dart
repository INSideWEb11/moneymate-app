// lib/presentation/activity/activity_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'widgets/review_queue_card.dart';
import 'widgets/transaction_tile.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _filter = 'All';
  final _searchController = TextEditingController();

  final List<String> _filters = [
    'All', 'Expense', 'Income', 'Review',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final reviewQueue = txProvider.reviewQueue;

    TransactionType? typeFilter;
    if (_filter == 'Expense') typeFilter = TransactionType.expense;
    if (_filter == 'Income') typeFilter = TransactionType.income;

    List<Transaction> displayTxns;
    if (_filter == 'Review') {
      displayTxns = reviewQueue;
    } else {
      displayTxns = txProvider.transactions
          .where((t) => typeFilter == null || t.type == typeFilter)
          .toList();
    }

    final grouped = txProvider.getGroupedByDate(displayTxns);
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              txProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onChanged: txProvider.setSearchQuery,
                ),
                const SizedBox(height: 10),
                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final isSelected = _filter == f;
                      return FilterChip(
                        label: Text(
                          f == 'Review' && reviewQueue.isNotEmpty
                              ? 'Review (${reviewQueue.length})'
                              : f,
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _filter = f),
                        selectedColor:
                            Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: txProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayTxns.isEmpty
              ? _buildEmpty(context)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: _filter == 'Review'
                      ? reviewQueue.length
                      : dateKeys.length * 2,
                  itemBuilder: (context, index) {
                    if (_filter == 'Review') {
                      return ReviewQueueCard(
                        transaction: reviewQueue[index],
                        onConfirm: () =>
                            txProvider.markAsReviewed(reviewQueue[index].id),
                        onDismiss: () =>
                            txProvider.markAsDuplicate(reviewQueue[index].id),
                        onChangeCategory: (cat) =>
                            _showCategoryPicker(context, reviewQueue[index]),
                      );
                    }

                    final groupIndex = index ~/ 2;
                    final isHeader = index % 2 == 0;

                    if (groupIndex >= dateKeys.length) return const SizedBox();

                    final dateKey = dateKeys[groupIndex];
                    final txns = grouped[dateKey]!;

                    if (isHeader) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: Text(
                          dateKey,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txns.length,
                        separatorBuilder: (_, __) => Divider(
                          indent: 72,
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        itemBuilder: (_, i) => TransactionTile(
                          transaction: txns[i],
                          showDate: false,
                          onTap: () =>
                              _showTransactionDetail(context, txns[i]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _filter == 'Review'
                ? 'All caught up! No items to review.'
                : 'No transactions found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, Transaction tx) {
    // Simple detail bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TransactionDetailSheet(transaction: tx),
    );
  }

  void _showCategoryPicker(BuildContext context, Transaction tx) {
    final txProvider = context.read<TransactionProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryPickerSheet(
        currentCategory: tx.category,
        onSelect: (cat) {
          txProvider.updateCategory(tx.id, cat);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                transaction.merchantName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          _row(context, 'Amount',
              '₹${transaction.amount.toStringAsFixed(2)}'),
          _row(context, 'Category', transaction.category),
          _row(context, 'Type', transaction.type.displayName),
          _row(context, 'Date', transaction.date.toString().substring(0, 16)),
          _row(context, 'Source', transaction.source.displayName),
          if (transaction.notes.isNotEmpty)
            _row(context, 'Notes', transaction.notes),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
          ),
          Expanded(
              child: Text(value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final String currentCategory;
  final Function(String) onSelect;

  const _CategoryPickerSheet(
      {required this.currentCategory, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('Select Category',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.allCategories.length,
            itemBuilder: (_, i) {
              final cat = AppConstants.allCategories[i];
              return ListTile(
                title: Text(cat),
                selected: cat == currentCategory,
                selectedColor: Theme.of(context).colorScheme.primary,
                onTap: () => onSelect(cat),
              );
            },
          ),
        ),
      ],
    );
  }
}
