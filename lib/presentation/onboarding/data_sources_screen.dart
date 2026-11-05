// lib/presentation/onboarding/data_sources_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DataSourcesScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DataSourcesScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Data Sync & Consent',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We value your privacy. MoneyMate processes financial data locally on your device.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Option 1: Manual & CSV (Recommended & Active)
          _buildSourceCard(
            title: 'Manual & Statement/CSV Import',
            subtitle: 'Recommended • Works completely offline • Private',
            status: 'Active',
            statusColor: Colors.green,
            icon: Icons.upload_file_outlined,
            isCurrent: true,
          ),
          const SizedBox(height: 14),

          // Option 2: Android Financial SMS Parser
          _buildSourceCard(
            title: 'On-Device SMS Transaction Parsing',
            subtitle: 'Parses bank debit/credit alerts locally. Requires Google Play permission disclosure.',
            status: 'Ready (Requires Opt-in)',
            statusColor: Colors.blue.shade700,
            icon: Icons.sms_outlined,
            isCurrent: false,
          ),
          const SizedBox(height: 14),

          // Option 3: Account Aggregator (RBI AA Framework)
          _buildSourceCard(
            title: 'RBI Account Aggregator (AA)',
            subtitle: 'Consent-based bank linking via licensed FIU/FIP gateway.',
            status: 'Coming Soon',
            statusColor: Colors.orange.shade700,
            icon: Icons.account_balance_outlined,
            isCurrent: false,
          ),

          const Spacer(),
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
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Proceed to Review', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSourceCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? AppTheme.primaryColor : Colors.grey.shade300,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
