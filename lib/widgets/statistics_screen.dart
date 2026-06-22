import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/chart_widget.dart';



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

            // Monthly summary starts by filtering all transactions.
            // Only transactions from the selected month and year are included.
            final monthlyTransactions = transactions.where((transaction) {
              return transaction.date.month == selectedMonth &&
                  transaction.date.year == selectedYear;
            }).toList();

            // Income total:
            // 1. Keep only income transactions.
            // 2. Add each income amount into one total.
            final incomeTotal = monthlyTransactions
                .where(
                  (transaction) => transaction.type == TransactionType.income,
                )
                .fold<double>(
                  0,
                  (total, transaction) => total + transaction.amount,
                );

            // Expense total:
            // 1. Keep only expense transactions.
            // 2. Add each expense amount into one total.
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
            // If this number is positive, the user saved money this month.
            // If this number is negative, the user spent more than they earned.
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

                  // ChartWidget receives all transactions plus the selected month/year.
                  // The chart widget handles filtering and drawing income vs expense.
                  ChartWidget(
                    transactions: transactions,
                    selectedMonth: selectedMonth,
                    selectedYear: selectedYear,
                  ),
                  const SizedBox(height: 24),

                  _StatisticCard(
                    title: 'Income Total',
                    amount: incomeTotal,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _StatisticCard(
                    title: 'Expense Total',
                    amount: expenseTotal,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _StatisticCard(
                    title: 'Savings',
                    amount: savings,
                    color: savings >= 0 ? Colors.blue : Colors.orange,
                  ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
