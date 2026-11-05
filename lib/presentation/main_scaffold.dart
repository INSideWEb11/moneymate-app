// lib/presentation/main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import 'activity/activity_screen.dart';
import 'add_transaction/add_transaction_sheet.dart';
import 'bills/bills_screen.dart';
import 'budget/budget_screen.dart';
import 'goals/goals_screen.dart';
import 'home/home_screen.dart';
import 'providers/commitment_provider.dart';
import 'providers/transaction_provider.dart';

class MainScaffold extends StatefulWidget {
  final Widget? child;

  const MainScaffold({super.key, this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ActivityScreen(),
    BudgetScreen(),
    BillsScreen(),
    GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    final reviewCount =
        context.watch<TransactionProvider>().reviewCount;

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: reviewCount > 0
              ? Badge.count(
                  count: reviewCount,
                  child: const Icon(Icons.receipt_long_outlined),
                )
              : const Icon(Icons.receipt_long_outlined),
          activeIcon: reviewCount > 0
              ? Badge.count(
                  count: reviewCount,
                  child: const Icon(Icons.receipt_long),
                )
              : const Icon(Icons.receipt_long),
          label: 'Activity',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart_outline),
          activeIcon: Icon(Icons.pie_chart),
          label: 'Budget',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Bills',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.savings_outlined),
          activeIcon: Icon(Icons.savings),
          label: 'Goals',
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddSheet(context),
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }
}
