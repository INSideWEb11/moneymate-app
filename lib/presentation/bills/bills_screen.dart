// lib/presentation/bills/bills_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/commitment.dart';
import '../providers/commitment_provider.dart';
import 'widgets/emi_card.dart';
import 'widgets/insurance_card.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommitmentProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bills & Commitments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'EMIs'),
              Tab(text: 'Insurance'),
              Tab(text: 'Others'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EmiTab(emis: provider.emis, provider: provider),
            _InsuranceTab(insurances: provider.insurances),
            _BillsTab(bills: provider.bills, provider: provider),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddCommitmentSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
    );
  }

  void _showAddCommitmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddCommitmentSheet(),
    );
  }
}

class _EmiTab extends StatelessWidget {
  final List<Commitment> emis;
  final CommitmentProvider provider;

  const _EmiTab({required this.emis, required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalEmi = emis.fold(0.0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Summary
        _buildSummaryChip(context, 'Total EMIs/month',
            CurrencyFormatter.format(totalEmi, showDecimal: false),
            AppTheme.primaryGreen),
        const SizedBox(height: 12),

        if (emis.isEmpty)
          _buildEmpty(context, 'No EMIs added yet')
        else
          ...emis.map((emi) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: EmiCard(
                  emi: emi,
                  onMarkPaid: () => provider.markPaid(emi.id),
                ),
              )),
      ],
    );
  }
}

class _InsuranceTab extends StatelessWidget {
  final List<Commitment> insurances;

  const _InsuranceTab({required this.insurances});

  @override
  Widget build(BuildContext context) {
    final totalReserve =
        insurances.fold(0.0, (s, i) => s + i.monthlyReserve);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _buildSummaryChip(
          context,
          'Monthly Reserve',
          CurrencyFormatter.format(totalReserve, showDecimal: false),
          AppTheme.infoBlue,
          subtitle: 'Set aside monthly for insurance renewals',
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.infoBlue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.infoBlue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppTheme.infoBlue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MoneyMate reserves a monthly amount so your annual premium never catches you off guard.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        if (insurances.isEmpty)
          _buildEmpty(context, 'No insurance policies added yet')
        else
          ...insurances.map((ins) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InsuranceCard(insurance: ins),
              )),
      ],
    );
  }
}

class _BillsTab extends StatelessWidget {
  final List<Commitment> bills;
  final CommitmentProvider provider;

  const _BillsTab({required this.bills, required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = bills.fold(0.0, (s, b) => s + b.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _buildSummaryChip(context, 'Total Bills/month',
            CurrencyFormatter.format(total, showDecimal: false),
            AppTheme.warningAmber),
        const SizedBox(height: 12),

        if (bills.isEmpty)
          _buildEmpty(context, 'No bills added yet')
        else
          ...bills.map((bill) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BillCard(bill: bill, provider: provider),
              )),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  final Commitment bill;
  final CommitmentProvider provider;

  const _BillCard({required this.bill, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_outlined,
                color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.name,
                    style: Theme.of(context).textTheme.titleSmall),
                Text(bill.lender,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(bill.amount, showDecimal: false),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => provider.markPaid(bill.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bill.isPaid
                        ? AppTheme.successGreen.withOpacity(0.1)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: bill.isPaid
                          ? AppTheme.successGreen
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Text(
                    bill.isPaid ? 'Paid' : 'Mark Paid',
                    style: TextStyle(
                      color: bill.isPaid
                          ? AppTheme.successGreen
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildSummaryChip(
    BuildContext context, String label, String value, Color color,
    {String? subtitle}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    )),
            if (subtitle != null)
              Text(subtitle,
                  style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    ),
  );
}

Widget _buildEmpty(BuildContext context, String msg) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 48,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(msg,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  )),
        ],
      ),
    ),
  );
}

// Add Commitment Sheet
class _AddCommitmentSheet extends StatefulWidget {
  const _AddCommitmentSheet();

  @override
  State<_AddCommitmentSheet> createState() => _AddCommitmentSheetState();
}

class _AddCommitmentSheetState extends State<_AddCommitmentSheet> {
  CommitmentType _type = CommitmentType.loanEmi;
  final _nameCtrl = TextEditingController();
  final _lenderCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  int? _remaining;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Add Commitment',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CommitmentType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: CommitmentType.values.map((t) {
              return DropdownMenuItem(
                  value: t, child: Text(t.displayName));
            }).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 10),
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 10),
          TextField(
              controller: _lenderCtrl,
              decoration: const InputDecoration(
                  labelText: 'Lender / Insurer')),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            decoration: const InputDecoration(
                labelText: 'Amount (₹)', prefixText: '₹ '),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Add Commitment'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (_nameCtrl.text.isEmpty || amount <= 0) return;

    final commitment = Commitment(
      name: _nameCtrl.text,
      lender: _lenderCtrl.text.isEmpty ? 'Unknown' : _lenderCtrl.text,
      amount: amount,
      monthlyReserve: amount,
      type: _type,
      dueDate: _dueDate,
      startDate: DateTime.now(),
    );

    context.read<CommitmentProvider>().add(commitment);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lenderCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }
}
