import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';


// HomeScreen is a StatelessWidget because the transaction data comes from Provider.
// The screen itself does not need to own local state.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer listens to TransactionProvider.
    // When notifyListeners() is called in the provider, this builder runs again.
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        // Gets all transactions from the provider.
        final transactions = transactionProvider.transactions;

        // Calculates total income by filtering income transactions and adding their amounts.
        final totalIncome = transactions
            .where((transaction) => transaction.type == TransactionType.income)
            .fold<double>(
              0,
              (total, transaction) => total + transaction.amount,
            );

        // Calculates total expense by filtering expense transactions and adding their amounts.
        final totalExpense = transactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .fold<double>(
              0,
              (total, transaction) => total + transaction.amount,
            );

        // Balance is income minus expense.
        final balance = totalIncome - totalExpense;

        // Scaffold gives the screen its main structure:
        // app bar at the top and body content below it.
        return Scaffold(
          // AppBar is the top bar of the screen.
          // It usually contains the page title and actions.
          appBar: AppBar(
            title: const Text('Money Buddy'),
          ),

          // SafeArea keeps content away from notches, status bars, and system UI.
          body: SafeArea(
            // Padding adds space around the screen content.
            child: Padding(
              padding: const EdgeInsets.all(16),

              // Column arranges widgets vertically.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row arranges the summary cards horizontally.
                  Row(
                    children: [
                      // Expanded lets each card share the available row width.
                      Expanded(
                        child: _SummaryCard(
                          title: 'Income',
                          amount: totalIncome,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Expense',
                          amount: totalExpense,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Balance card uses the full width so it feels more important.
                  _SummaryCard(
                    title: 'Balance',
                    amount: balance,
                    color: balance >= 0 ? Colors.blue : Colors.orange,
                  ),
                  const SizedBox(height: 24),

                  // Text is used here as a simple section heading.
                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Expanded gives the transaction list the remaining screen height.
                  Expanded(
                    // Shows an empty message when there are no transactions yet.
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text('No transactions yet'),
                          )

                        // ListView.builder creates list items only when they are needed.
                        // This is better than creating all rows at once for long lists.
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];

                              return _TransactionTile(
                                transaction: transaction,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// This private widget displays one summary value, like income, expense, or balance.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Card gives the summary a separate visual container.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This private widget displays one transaction row in the ListView.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    // ListTile is a ready-made row widget with title, subtitle, leading icon, and trailing text.
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green : Colors.red,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
