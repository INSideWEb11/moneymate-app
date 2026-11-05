// lib/presentation/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/commitment.dart';
import '../../data/models/goal.dart';
import '../../data/models/income.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/commitment_repository.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../providers/budget_provider.dart';
import '../providers/commitment_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_profile_provider.dart';
import 'welcome_screen.dart';
import 'income_setup_screen.dart';
import 'commitments_setup_screen.dart';
import 'data_sources_screen.dart';
import 'review_plan_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding accumulated data
  String _userName = '';
  double _monthlyIncome = 60000.0;
  int _payday = 1;
  String _payCycle = '1st';
  String _incomeType = 'received';

  // Commitments
  double _rentAmount = 0.0;
  double _emiAmount = 0.0;
  String _emiLender = '';
  double _insurancePremium = 0.0;
  String _insuranceType = 'Health';
  double _savingsTarget = 10000.0;

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsFirstLaunch, false);
    await prefs.setBool(AppConstants.prefOnboardingComplete, true);

    if (!mounted) return;

    // Create user profile
    final profile = UserProfile(
      name: _userName.trim().isEmpty ? 'Friend' : _userName.trim(),
      monthlyIncome: _monthlyIncome,
      paydayOfMonth: _payday,
      payCycle: _payCycle,
    );

    final budgetRepo = BudgetRepository();
    await budgetRepo.updateUserProfile(profile);

    // Add Income
    final income = IncomeSource(
      name: 'Primary Salary',
      amount: _monthlyIncome,
      type: IncomeType.salary,
      paydayOfMonth: _payday,
      isReceivedThisCycle: _incomeType == 'received',
      isRegular: true,
    );
    await budgetRepo.insertIncomeSource(income);

    // Add Commitments if entered
    final commRepo = CommitmentRepository();
    if (_rentAmount > 0) {
      await commRepo.insert(Commitment(
        name: 'House Rent',
        amount: _rentAmount,
        monthlyReserve: _rentAmount,
        type: CommitmentType.rentBill,
        dueDate: DateTime(DateTime.now().year, DateTime.now().month, _payday),
        startDate: DateTime.now(),
      ));
    }
    if (_emiAmount > 0) {
      await commRepo.insert(Commitment(
        name: _emiLender.isEmpty ? 'Personal / Gadget Loan EMI' : '$_emiLender EMI',
        lender: _emiLender.isEmpty ? 'Bank' : _emiLender,
        amount: _emiAmount,
        monthlyReserve: _emiAmount,
        type: CommitmentType.loanEmi,
        dueDate: DateTime(DateTime.now().year, DateTime.now().month, 10),
        startDate: DateTime.now(),
        remainingInstallments: 12,
      ));
    }
    if (_insurancePremium > 0) {
      await commRepo.insert(Commitment(
        name: '$_insuranceType Insurance',
        lender: 'Insurance Provider',
        amount: _insurancePremium,
        monthlyReserve: (_insurancePremium / 12).roundToDouble(),
        type: _insuranceType == 'Car'
            ? CommitmentType.carInsurance
            : (_insuranceType == 'Bike'
                ? CommitmentType.bikeInsurance
                : CommitmentType.healthInsurance),
        dueDate: DateTime(DateTime.now().year, DateTime.now().month + 6, 15),
        startDate: DateTime.now(),
      ));
    }

    // Add Goal
    if (_savingsTarget > 0) {
      final goalRepo = GoalRepository();
      await goalRepo.insert(SavingsGoal(
        name: 'Emergency Fund',
        targetAmount: _savingsTarget * 6,
        currentAmount: _savingsTarget,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        monthlyContribution: _savingsTarget,
      ));
    }

    // Reload all providers
    final profileProvider = context.read<UserProfileProvider>();
    final txProvider = context.read<TransactionProvider>();
    final commitmentProvider = context.read<CommitmentProvider>();
    final goalProvider = context.read<GoalProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    await profileProvider.loadProfile();
    await commitmentProvider.load();
    await goalProvider.load();
    await txProvider.load();

    await budgetProvider.load(
      commitments: commitmentProvider.commitments,
      goals: goalProvider.activeGoals,
      totalVariableSpend: 0.0,
      paydayOfMonth: _payday,
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  WelcomeScreen(
                    initialName: _userName,
                    onNameChanged: (val) => _userName = val,
                    onNext: _nextPage,
                  ),
                  IncomeSetupScreen(
                    initialIncome: _monthlyIncome,
                    initialPayday: _payday,
                    initialPayCycle: _payCycle,
                    onIncomeChanged: (val) => _monthlyIncome = val,
                    onPaydayChanged: (val) => _payday = val,
                    onPayCycleChanged: (val) => _payCycle = val,
                    onIncomeTypeChanged: (val) => _incomeType = val,
                    onNext: _nextPage,
                    onBack: _prevPage,
                  ),
                  CommitmentsSetupScreen(
                    onRentChanged: (val) => _rentAmount = val,
                    onEmiChanged: (amt, lender) {
                      _emiAmount = amt;
                      _emiLender = lender;
                    },
                    onInsuranceChanged: (amt, type) {
                      _insurancePremium = amt;
                      _insuranceType = type;
                    },
                    onSavingsChanged: (val) => _savingsTarget = val,
                    onNext: _nextPage,
                    onBack: _prevPage,
                  ),
                  DataSourcesScreen(
                    onNext: _nextPage,
                    onBack: _prevPage,
                  ),
                  ReviewPlanScreen(
                    userName: _userName.isEmpty ? 'Swasthik' : _userName,
                    monthlyIncome: _monthlyIncome,
                    payday: _payday,
                    payCycle: _payCycle,
                    rentAmount: _rentAmount,
                    emiAmount: _emiAmount,
                    insurancePremium: _insurancePremium,
                    savingsTarget: _savingsTarget,
                    onFinish: _finishOnboarding,
                    onBack: _prevPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
