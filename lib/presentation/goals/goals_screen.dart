// lib/presentation/goals/goals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/goal.dart';
import '../providers/goal_provider.dart';
import 'widgets/goal_progress_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final goals = provider.activeGoals;
    final totalSaved = provider.totalSaved;
    final totalMonthly = provider.totalMonthlyContribution;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      body: goals.isEmpty && !provider.isLoading
          ? _buildEmpty(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                // Summary header
                if (goals.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen,
                          AppTheme.primaryGreenLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Saved',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                CurrencyFormatter.formatCompact(totalSaved),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: Colors.white30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Monthly Saving',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '${CurrencyFormatter.format(totalMonthly, showDecimal: false)}/mo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Text('Active Goals (${goals.length})',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),

                ...goals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GoalProgressCard(
                        goal: goal,
                        onContribute: () =>
                            _showContributeSheet(context, goal),
                        onEdit: () => _showEditGoalSheet(context, goal),
                        onDelete: () => provider.delete(goal.id),
                      ),
                    )),

                // Completed goals
                if (provider.completedGoals.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Completed',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...provider.completedGoals.map(
                    (g) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.successGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppTheme.successGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(g.name,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(g.targetAmount),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.successGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3)),
            const SizedBox(height: 20),
            Text('No savings goals yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Create a goal to start saving for things that matter to you.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showContributeSheet(BuildContext context, Goal goal) {
    final ctrl = TextEditingController(
        text: goal.monthlyContribution.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contribute to "${goal.name}"',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(ctrl.text) ?? 0;
                if (amount > 0) {
                  context.read<GoalProvider>().contribute(goal.id, amount);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Contribution'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddGoalSheet(),
    );
  }

  void _showEditGoalSheet(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddGoalSheet(existingGoal: goal),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  final Goal? existingGoal;
  const _AddGoalSheet({this.existingGoal});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _monthlyCtrl;
  late GoalCategory _category;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetCtrl = TextEditingController(
        text: g?.targetAmount.toStringAsFixed(0) ?? '');
    _monthlyCtrl = TextEditingController(
        text: g?.monthlyContribution.toStringAsFixed(0) ?? '');
    _category = g?.category ?? GoalCategory.other;
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                    widget.existingGoal == null
                        ? 'New Goal'
                        : 'Edit Goal',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GoalCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: GoalCategory.values.map((c) {
                return DropdownMenuItem(
                    value: c, child: Text(c.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 10),
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Goal Name')),
            const SizedBox(height: 10),
            TextField(
              controller: _targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Target Amount (₹)', prefixText: '₹ '),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _monthlyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Monthly Contribution (₹)',
                  prefixText: '₹ '),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.existingGoal == null ? 'Create Goal' : 'Update Goal'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _save() {
    final target = double.tryParse(_targetCtrl.text) ?? 0;
    final monthly = double.tryParse(_monthlyCtrl.text) ?? 0;
    if (_nameCtrl.text.isEmpty || target <= 0) return;

    final provider = context.read<GoalProvider>();

    if (widget.existingGoal != null) {
      provider.update(widget.existingGoal!.copyWith(
        name: _nameCtrl.text,
        category: _category,
        targetAmount: target,
        monthlyContribution: monthly,
        targetDate: _targetDate,
      ));
    } else {
      provider.add(Goal(
        name: _nameCtrl.text,
        category: _category,
        targetAmount: target,
        monthlyContribution: monthly,
        targetDate: _targetDate,
      ));
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }
}
