// lib/presentation/onboarding/commitments_setup_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CommitmentsSetupScreen extends StatefulWidget {
  final ValueChanged<double> onRentChanged;
  final Function(double amt, String lender) onEmiChanged;
  final Function(double amt, String type) onInsuranceChanged;
  final ValueChanged<double> onSavingsChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CommitmentsSetupScreen({
    super.key,
    required this.onRentChanged,
    required this.onEmiChanged,
    required this.onInsuranceChanged,
    required this.onSavingsChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CommitmentsSetupScreen> createState() => _CommitmentsSetupScreenState();
}

class _CommitmentsSetupScreenState extends State<CommitmentsSetupScreen> {
  final _rentCtrl = TextEditingController();
  final _emiAmtCtrl = TextEditingController();
  final _emiLenderCtrl = TextEditingController();
  final _insAmtCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController(text: '10000');
  String _insType = 'Health';

  @override
  void dispose() {
    _rentCtrl.dispose();
    _emiAmtCtrl.dispose();
    _emiLenderCtrl.dispose();
    _insAmtCtrl.dispose();
    _savingsCtrl.dispose();
    super.dispose();
  }

  void _applyChanges() {
    final rent = double.tryParse(_rentCtrl.text) ?? 0.0;
    final emi = double.tryParse(_emiAmtCtrl.text) ?? 0.0;
    final ins = double.tryParse(_insAmtCtrl.text) ?? 0.0;
    final savings = double.tryParse(_savingsCtrl.text) ?? 0.0;

    widget.onRentChanged(rent);
    widget.onEmiChanged(emi, _emiLenderCtrl.text.trim());
    widget.onInsuranceChanged(ins, _insType);
    widget.onSavingsChanged(savings);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Commitments & Baseline',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add what you know. All fields are optional — you can add or adjust these anytime later.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Fixed Rent / Bills
          _buildSectionHeader('Fixed Monthly Rent / Utilities', Icons.home_work_outlined),
          const SizedBox(height: 8),
          TextField(
            controller: _rentCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 15000',
              prefixText: '₹ ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Loan EMIs
          _buildSectionHeader('Monthly Loan / Gadget EMI', Icons.credit_card_outlined),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _emiAmtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount (₹)',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: _emiLenderCtrl,
                  decoration: InputDecoration(
                    hintText: 'Lender (e.g. HDFC)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Insurance Policies
          _buildSectionHeader('Insurance Policy Premium', Icons.shield_outlined),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _insAmtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Annual (₹)',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _insType,
                      isExpanded: true,
                      items: ['Health', 'Bike', 'Car', 'Life'].map((t) {
                        return DropdownMenuItem(value: t, child: Text('$t Insurance'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _insType = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Savings Target
          _buildSectionHeader('Target Monthly Savings', Icons.savings_outlined),
          const SizedBox(height: 8),
          TextField(
            controller: _savingsCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 10000',
              prefixText: '₹ ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),

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
                    onPressed: () {
                      _applyChanges();
                      widget.onNext();
                    },
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
