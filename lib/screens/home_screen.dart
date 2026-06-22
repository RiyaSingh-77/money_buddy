import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

// Before using this file, make sure Provider is installed:
// flutter pub add provider
//
// This file should be placed at:
// lib/screens/home_screen.dart
//
// It depends on:
// lib/models/transaction_model.dart
// lib/providers/transaction_provider.dart
// lib/screens/add_transaction_screen.dart

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

        final totalIncome = transactions
            .where((transaction) => transaction.type == TransactionType.income)
            .fold<double>(
              0,
              (total, transaction) => total + transaction.amount,
            );

        final totalExpense = transactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .fold<double>(
              0,
              (total, transaction) => total + transaction.amount,
            );

        final balance = totalIncome - totalExpense;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Money Buddy'),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
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
                  _SummaryCard(
                    title: 'Balance',
                    amount: balance,
                    color: balance >= 0 ? Colors.blue : Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text('No transactions yet'),
                          )
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

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
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${isIncome ? 'Income' : 'Expense'}',
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