import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

// StatisticsScreen shows the current month's income, expense, and savings,
// plus two charts (pie + bar) that visualize the same numbers two different
// ways. It listens to TransactionProvider directly, so it always reflects
// the latest data — no manual refresh needed after adding, editing, or
// deleting a transaction.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DateTime.now() gives the current date.
    // We use it to show statistics for the current month and year.
    final now = DateTime.now();
    final selectedMonth = now.month;
    final selectedYear = now.year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            final transactions = transactionProvider.transactions;

            // Only transactions from the selected month and year are included.
            final monthlyTransactions = transactions.where((transaction) {
              return transaction.date.month == selectedMonth &&
                  transaction.date.year == selectedYear;
            }).toList();

            // Income total: keep only income transactions, add their amounts.
            final incomeTotal = monthlyTransactions
                .where(
                  (transaction) => transaction.type == TransactionType.income,
                )
                .fold<double>(
                  0,
                  (total, transaction) => total + transaction.amount,
                );

            // Expense total: keep only expense transactions, add their amounts.
            final expenseTotal = monthlyTransactions
                .where(
                  (transaction) => transaction.type == TransactionType.expense,
                )
                .fold<double>(
                  0,
                  (total, transaction) => total + transaction.amount,
                );

            // Savings calculation:
            // savings = income - expense
            // Positive means the user saved money this month.
            // Negative means they spent more than they earned.
            final savings = incomeTotal - expenseTotal;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Monthly Summary',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  _StatisticCard(
                    title: 'Monthly Income',
                    amount: incomeTotal,
                    color: const Color(0xFF168A4A),
                  ),
                  const SizedBox(height: 12),
                  _StatisticCard(
                    title: 'Monthly Expense',
                    amount: expenseTotal,
                    color: const Color(0xFFD43D32),
                  ),
                  const SizedBox(height: 12),
                  _StatisticCard(
                    title: 'Monthly Savings',
                    amount: savings,
                    color: savings >= 0
                        ? const Color(0xFF2364AA)
                        : const Color(0xFFE07828),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Income vs Expense',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // PieChartWidget and BarChartWidget are both reusable —
                  // they only need the two totals, not the transaction list.
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PieChartWidget(
                        income: incomeTotal,
                        expense: expenseTotal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Monthly Comparison',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BarChartWidget(
                        income: incomeTotal,
                        expense: expenseTotal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// This small private widget avoids repeating the same card UI three times.
class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withOpacity(0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
