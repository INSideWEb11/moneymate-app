// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../providers/budget_provider.dart';
import '../providers/commitment_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_profile_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/coach_insight_card.dart';
import 'widgets/recent_transactions_widget.dart';
import 'widgets/safe_to_spend_card.dart';
import 'widgets/savings_progress_card.dart';
import 'widgets/upcoming_commitment_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final commitmentProvider = context.watch<CommitmentProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final greeting = AppDateUtils.getGreeting();
    final name = profileProvider.name;
    final calc = budgetProvider.calculation;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await txProvider.load();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Safe to Spend Card
                  if (calc != null)
                    SafeToSpendCard(calculation: calc)
                  else
                    _buildLoadingCard(context, height: 180),

                  const SizedBox(height: 12),

                  // Upcoming Commitment
                  if (commitmentProvider.nextDue != null)
                    UpcomingCommitmentCard(
                      commitment: commitmentProvider.nextDue!,
                    ),

                  const SizedBox(height: 12),

                  // Coach Insight
                  if (budgetProvider.coachInsight.isNotEmpty)
                    CoachInsightCard(
                      insight: budgetProvider.coachInsight,
                      status: calc?.status,
                    ),

                  const SizedBox(height: 12),

                  // Savings Progress
                  if (goalProvider.activeGoals.isNotEmpty)
                    SavingsProgressCard(
                      goals: goalProvider.activeGoals,
                      totalSaved: goalProvider.totalSaved,
                    ),

                  const SizedBox(height: 12),

                  // Recent Transactions
                  _buildSectionHeader(context, 'Recent Activity'),
                  const SizedBox(height: 8),
                  RecentTransactionsWidget(
                    transactions: txProvider.getRecent(5),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, {double height = 120}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextButton(
          onPressed: () {},
          child: const Text('See all'),
        ),
      ],
    );
  }
}
