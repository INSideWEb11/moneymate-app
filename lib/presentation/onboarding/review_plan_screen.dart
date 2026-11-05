// lib/presentation/onboarding/review_plan_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';

class ReviewPlanScreen extends StatelessWidget {
  final String userName;
  final double monthlyIncome;
  final int payday;
  final String payCycle;
  final double rentAmount;
  final double emiAmount;
  final double insurancePremium;
  final double savingsTarget;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const ReviewPlanScreen({
    super.key,
    required this.userName,
    required this.monthlyIncome,
    required this.payday,
    required this.payCycle,
    required this.rentAmount,
    required this.emiAmount,
    required this.insurancePremium,
    required this.savingsTarget,
    required this.onFinish,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Blueprint logic calculation:
    // monthly_insurance_reserve = annualPremium / 12
    final monthlyInsReserve = insurancePremium > 0 ? (insurancePremium / 12).roundToDouble() : 0.0;
    final totalCommitments = rentAmount + emiAmount + monthlyInsReserve;
    final flexibleBudget = monthlyIncome - totalCommitments - savingsTarget;
    final daysInCycle = 30;
    final dailySafeSpend = flexibleBudget > 0 ? (flexibleBudget / daysInCycle) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Review Your Starting Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Here is the personal cash-flow baseline for $userName:',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Safe To Spend Preview Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED DAILY SAFE TO SPEND',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(dailySafeSpend),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Flexible budget: ${CurrencyFormatter.format(flexibleBudget)} for $daysInCycle days',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary breakdown
          _buildItemRow('Monthly Take-Home', CurrencyFormatter.format(monthlyIncome), isHighlight: true),
          const Divider(height: 24),
          _buildItemRow('Reserved Commitments', '- ${CurrencyFormatter.format(totalCommitments)}'),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
            child: Column(
              children: [
                if (rentAmount > 0) _buildSubRow('Rent & Bills', CurrencyFormatter.format(rentAmount)),
                if (emiAmount > 0) _buildSubRow('Loan EMIs', CurrencyFormatter.format(emiAmount)),
                if (monthlyInsReserve > 0)
                  _buildSubRow('Insurance Reserve (1/12th)', CurrencyFormatter.format(monthlyInsReserve)),
              ],
            ),
          ),
          _buildItemRow('Target Savings', '- ${CurrencyFormatter.format(savingsTarget)}'),
          const Divider(height: 24),
          _buildItemRow(
            'Remaining Flexible Cash',
            CurrencyFormatter.format(flexibleBudget),
            isBold: true,
            color: flexibleBudget > 0 ? AppTheme.primaryColor : Colors.red,
          ),
          const SizedBox(height: 36),

          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create My Plan & Launch App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildItemRow(String label, String value, {bool isHighlight = false, bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight || isBold ? 15 : 14,
            fontWeight: isHighlight || isBold ? FontWeight.bold : FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight || isBold ? 15 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? (isHighlight ? AppTheme.primaryColor : AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSubRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
