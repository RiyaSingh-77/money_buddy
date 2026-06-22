import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

// MonthlySummaryWidget is a small, self-contained, reusable widget that
// reads straight from TransactionProvider via Consumer. Because it listens
// to the provider itself, it can be dropped into any screen (HomeScreen,
// StatisticsScreen, its own screen, etc.) with zero extra wiring — it always
// shows up-to-date numbers for the current month, and rebuilds automatically
// whenever a transaction is added, edited, or deleted.
class MonthlySummaryWidget extends StatelessWidget {
  const MonthlySummaryWidget({super.key});

  // Plain English names for DateTime.month (1-12), used since the intl
  // package isn't a dependency of this project.
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Builds an encouraging or cautionary message based on how the month
  // is going. Keeping this as its own method makes the logic easy to
  // read and easy to tweak independently of the layout code below.
  String _motivationalMessage(double income, double expense, double savings) {
    if (income == 0 && expense == 0) {
      return 'No transactions yet this month. Add one to get started!';
    }

    if (income == 0) {
      return 'No income recorded yet this month — keep an eye on those expenses.';
    }

    if (savings < 0) {
      return 'You spent more than you earned this month. Let\'s tighten the budget next month.';
    }

    if (savings == 0) {
      return 'You broke even this month. Try saving a little next month!';
    }

    // savings > 0 from here on.
    final savingsRate = savings / income;

    if (savingsRate >= 0.3) {
      return 'Amazing! You saved over 30% of your income this month. Keep it up!';
    }

    if (savingsRate >= 0.1) {
      return 'Nice work! You\'re building healthy savings habits this month.';
    }

    return 'You saved a little this month. Every bit adds up!';
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to TransactionProvider directly, so this widget
    // refreshes on its own whenever the provider's data changes.
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final now = DateTime.now();
        final selectedMonth = now.month;
        final selectedYear = now.year;

        final transactions = transactionProvider.transactions;

        // Only transactions from the current month and year are included.
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

        // Savings = income - expense.
        final savings = incomeTotal - expenseTotal;

        final monthName = _monthNames[selectedMonth - 1];
        final message = _motivationalMessage(incomeTotal, expenseTotal, savings);

        final savingsColor = savings >= 0
            ? const Color(0xFF2364AA)
            : const Color(0xFFE07828);

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monthName $selectedYear',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),

                // Income and expense are shown side by side; LayoutBuilder
                // drops them into a column on very narrow widths instead.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useRow = constraints.maxWidth >= 320;

                    final incomeTile = _AmountTile(
                      label: 'Income',
                      amount: incomeTotal,
                      color: const Color(0xFF168A4A),
                      icon: Icons.trending_up,
                    );

                    final expenseTile = _AmountTile(
                      label: 'Expense',
                      amount: expenseTotal,
                      color: const Color(0xFFD43D32),
                      icon: Icons.trending_down,
                    );

                    if (useRow) {
                      return Row(
                        children: [
                          Expanded(child: incomeTile),
                          const SizedBox(width: 12),
                          Expanded(child: expenseTile),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        incomeTile,
                        const SizedBox(height: 12),
                        expenseTile,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Savings gets its own full-width row since it's the
                // headline number for the month.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Savings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '₹${savings.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: savingsColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 12),

                // Motivational message gives the numbers some context and
                // encouragement, rather than just raw figures.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      savings >= 0
                          ? Icons.emoji_events_outlined
                          : Icons.lightbulb_outline,
                      color: savingsColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Small private widget that displays one labeled amount with an icon,
// used for the income and expense tiles above.
class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
