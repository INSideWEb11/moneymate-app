// lib/presentation/onboarding/income_setup_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class IncomeSetupScreen extends StatefulWidget {
  final double initialIncome;
  final int initialPayday;
  final String initialPayCycle;
  final ValueChanged<double> onIncomeChanged;
  final ValueChanged<int> onPaydayChanged;
  final ValueChanged<String> onPayCycleChanged;
  final ValueChanged<String> onIncomeTypeChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const IncomeSetupScreen({
    super.key,
    required this.initialIncome,
    required this.initialPayday,
    required this.initialPayCycle,
    required this.onIncomeChanged,
    required this.onPaydayChanged,
    required this.onPayCycleChanged,
    required this.onIncomeTypeChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<IncomeSetupScreen> createState() => _IncomeSetupScreenState();
}

class _IncomeSetupScreenState extends State<IncomeSetupScreen> {
  late final TextEditingController _incomeCtrl;
  late int _selectedPayday;
  String _incomeStatus = 'received';

  @override
  void initState() {
    super.initState();
    _incomeCtrl = TextEditingController(text: widget.initialIncome.toInt().toString());
    _selectedPayday = widget.initialPayday;
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Income & Payday',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Required to establish your active budget cycle and available spendable cash.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),
          const Text(
            'Monthly Take-Home Income (₹)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _incomeCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              final amt = double.tryParse(val) ?? 0.0;
              widget.onIncomeChanged(amt);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Salary / Payday of the Month',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedPayday,
                isExpanded: true,
                items: [1, 5, 10, 15, 20, 25, 28, 30].map((day) {
                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text('Every $day${_getDaySuffix(day)} of the month'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPayday = val);
                    widget.onPaydayChanged(val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Current Month Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Already Received'),
                  selected: _incomeStatus == 'received',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _incomeStatus = 'received');
                      widget.onIncomeTypeChanged('received');
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Expected / Due'),
                  selected: _incomeStatus == 'expected',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _incomeStatus = 'expected');
                      widget.onIncomeTypeChanged('expected');
                    }
                  },
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}
