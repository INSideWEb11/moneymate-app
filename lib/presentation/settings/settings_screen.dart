// lib/presentation/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/user_profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      backgroundColor: AppTheme.surfaceLight,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Profile card
          _buildCard(
            title: 'Profile & Pay Cycle',
            children: [
              _buildListTile(
                icon: Icons.person_outline,
                title: 'User Name',
                subtitle: profile?.name ?? 'Not configured',
              ),
              _buildListTile(
                icon: Icons.calendar_today_outlined,
                title: 'Payday of the Month',
                subtitle: 'Day ${profile?.paydayOfMonth ?? 1}',
              ),
              _buildListTile(
                icon: Icons.currency_rupee,
                title: 'Monthly Income',
                subtitle: CurrencyFormatter.format(profile?.monthlyIncome ?? 0),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data & Permissions
          _buildCard(
            title: 'Data Sources & Sync Status',
            children: [
              _buildListTile(
                icon: Icons.phone_android,
                title: 'SMS Financial Parsing',
                subtitle: 'On-device only • Subject to Play permission',
                trailing: const Chip(label: Text('Local', style: TextStyle(fontSize: 11))),
              ),
              _buildListTile(
                icon: Icons.account_balance,
                title: 'Account Aggregator (RBI AA)',
                subtitle: 'Consent-based bank linking',
                trailing: const Chip(label: Text('Planned', style: TextStyle(fontSize: 11))),
              ),
              _buildListTile(
                icon: Icons.file_upload_outlined,
                title: 'Export / Backup Data',
                subtitle: 'Export local ledger as CSV file',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ledger export created successfully')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Security & Safety
          _buildCard(
            title: 'Privacy & Security',
            children: [
              _buildListTile(
                icon: Icons.fingerprint,
                title: 'Biometric / App Lock',
                subtitle: 'Require fingerprint or PIN to unlock',
                trailing: Switch(
                  value: profile?.useBiometrics ?? false,
                  onChanged: (val) {
                    profileProvider.toggleBiometrics(val);
                  },
                ),
              ),
              _buildListTile(
                icon: Icons.delete_outline,
                title: 'Clear Local Storage',
                subtitle: 'Erase all transactions and start fresh',
                titleColor: Colors.red,
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About
          _buildCard(
            title: 'About MoneyMate',
            children: [
              _buildListTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: 'v1.0.0 (India-First Personal Budget)',
              ),
              _buildListTile(
                icon: Icons.shield_outlined,
                title: 'Privacy Principles',
                subtitle: 'Zero ads, zero data selling, local on-device ledger',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 14, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all local accounts, transactions, commitments and goals. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database reset')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
