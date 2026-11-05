// lib/app.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/models/commitment.dart';
import 'data/models/goal.dart';
import 'data/models/income.dart';
import 'data/models/transaction.dart';
import 'data/models/user_profile.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/commitment_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'presentation/main_scaffold.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/commitment_provider.dart';
import 'presentation/providers/goal_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/user_profile_provider.dart';

class MoneyMateApp extends StatefulWidget {
  final bool isFirstLaunch;

  const MoneyMateApp({super.key, required this.isFirstLaunch});

  @override
  State<MoneyMateApp> createState() => _MoneyMateAppState();
}

class _MoneyMateAppState extends State<MoneyMateApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: widget.isFirstLaunch ? '/onboarding' : '/',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load all providers
    final profileProvider =
        context.read<UserProfileProvider>();
    final txProvider = context.read<TransactionProvider>();
    final commitmentProvider = context.read<CommitmentProvider>();
    final goalProvider = context.read<GoalProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    await profileProvider.loadProfile();
    await commitmentProvider.load();
    await goalProvider.load();
    await txProvider.load();

    if (profileProvider.hasProfile) {
      final payday = profileProvider.paydayOfMonth;
      final cycleStart = _getCycleStart(payday);
      final cycleEnd = _getCycleEnd(payday);

      final variableSpend = txProvider.getTotalVariableSpend(cycleStart, cycleEnd);

      await budgetProvider.load(
        commitments: commitmentProvider.commitments,
        goals: goalProvider.activeGoals,
        totalVariableSpend: variableSpend,
        paydayOfMonth: payday,
      );
    }

    // Seed demo data if first launch and no data exists
    if (AppConstants.enableDemoData && txProvider.allTransactions.isEmpty) {
      await _seedDemoData();
      await txProvider.load();
    }
  }

  Future<void> _seedDemoData() async {
    final txRepo = TransactionRepository();
    final commitmentRepo = CommitmentRepository();
    final goalRepo = GoalRepository();
    final budgetRepo = BudgetRepository();

    // Demo user profile
    final profile = UserProfile(
      name: 'Rahul',
      paydayOfMonth: 1,
      payCycle: '1st',
    );
    await budgetRepo.updateUserProfile(profile);

    // Demo income
    final income = IncomeSource(
      name: 'Salary - TechCorp',
      amount: 75000,
      type: IncomeType.salary,
      paydayOfMonth: 1,
      employerName: 'TechCorp Solutions',
      isRegular: true,
    );
    await budgetRepo.insertIncomeSource(income);

    // Demo EMI
    final emi = Commitment(
      name: 'Home Loan EMI',
      lender: 'HDFC Bank',
      amount: 18500,
      monthlyReserve: 18500,
      type: CommitmentType.loanEmi,
      dueDate: DateTime(DateTime.now().year, DateTime.now().month, 5),
      startDate: DateTime(2022, 6, 1),
      remainingInstallments: 180,
      loanAccountNumber: '****1234',
    );
    await commitmentRepo.insert(emi);

    // Demo insurance
    final insurance = Commitment(
      name: 'Health Insurance',
      lender: 'Star Health',
      amount: 24000,
      monthlyReserve: 2000,
      type: CommitmentType.healthInsurance,
      dueDate: DateTime(DateTime.now().year + 1, 3, 15),
      startDate: DateTime(2023, 3, 15),
      annualPremium: 24000,
      savingMonths: 12,
      policyReference: 'SH-2023-45678',
    );
    await commitmentRepo.insert(insurance);

    // Demo goal
    final goal = Goal(
      name: 'Emergency Fund',
      category: GoalCategory.emergency,
      targetAmount: 150000,
      currentAmount: 45000,
      monthlyContribution: 5000,
      targetDate: DateTime(DateTime.now().year + 2, 1, 1),
    );
    await goalRepo.insert(goal);

    // Demo transactions (last 15 days)
    final now = DateTime.now();
    final demoTxns = [
      Transaction(
        merchantName: 'Swiggy',
        category: 'Food & Dining',
        amount: 350,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'BigBasket',
        category: 'Groceries',
        amount: 2100,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 2)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'Uber',
        category: 'Transport',
        amount: 180,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 2)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'TechCorp Solutions',
        category: 'Salary',
        amount: 75000,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 5)),
        source: TransactionSource.manual,
        isReviewed: true,
      ),
      Transaction(
        merchantName: 'Amazon',
        category: 'Shopping',
        amount: 1599,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 6)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'Apollo Pharmacy',
        category: 'Health & Medical',
        amount: 450,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 8)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'Netflix',
        category: 'Entertainment',
        amount: 649,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 10)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'HDFC Bank - EMI',
        category: 'Other',
        amount: 18500,
        type: TransactionType.emiPayment,
        date: now.subtract(const Duration(days: 5)),
        source: TransactionSource.manual,
        linkedCommitmentId: emi.id,
      ),
      Transaction(
        merchantName: 'Zomato',
        category: 'Food & Dining',
        amount: 520,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
        source: TransactionSource.manual,
      ),
      Transaction(
        merchantName: 'Airtel Recharge',
        category: 'Utilities',
        amount: 719,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 12)),
        source: TransactionSource.manual,
      ),
    ];

    for (final tx in demoTxns) {
      await txRepo.insert(tx);
    }

    // Mark onboarding complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsFirstLaunch, false);
    await prefs.setBool(AppConstants.prefOnboardingComplete, true);
  }

  DateTime _getCycleStart(int payday) {
    final now = DateTime.now();
    if (now.day >= payday) {
      return DateTime(now.year, now.month, payday);
    } else {
      final prev = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      return DateTime(prevYear, prev, payday);
    }
  }

  DateTime _getCycleEnd(int payday) {
    final start = _getCycleStart(payday);
    final nextMonth = start.month == 12 ? 1 : start.month + 1;
    final nextYear = start.month == 12 ? start.year + 1 : start.year;
    return DateTime(nextYear, nextMonth, payday)
        .subtract(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        ThemeMode themeMode = ThemeMode.system;
        if (profileProvider.themeMode == 'light') themeMode = ThemeMode.light;
        if (profileProvider.themeMode == 'dark') themeMode = ThemeMode.dark;

        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          routerConfig: _router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
