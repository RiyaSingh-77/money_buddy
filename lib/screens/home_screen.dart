import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

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

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Money Buddy'),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useTwoColumns = constraints.maxWidth >= 520;

                      final incomeCard = _SummaryCard(
                        title: 'Income',
                        amount: totalIncome,
                        icon: Icons.trending_up,
                        color: const Color(0xFF168A4A),
                      );

                      final expenseCard = _SummaryCard(
                        title: 'Expense',
                        amount: totalExpense,
                        icon: Icons.trending_down,
                        color: const Color(0xFFD43D32),
                      );

                      if (useTwoColumns) {
                        return Row(
                          children: [
                            Expanded(child: incomeCard),
                            const SizedBox(width: 12),
                            Expanded(child: expenseCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          incomeCard,
                          const SizedBox(height: 12),
                          expenseCard,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Balance',
                    amount: balance,
                    icon: Icons.account_balance_wallet,
                    color: balance >= 0
                        ? const Color(0xFF2364AA)
                        : const Color(0xFFE07828),
                    isLarge: true,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      Text(
                        '${transactions.length} total',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: transactions.isEmpty
                        ? Center(
                            child: Text(
                              'No transactions yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 96),
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
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.14),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            SizedBox(height: isLarge ? 16 : 12),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

// This private widget displays one transaction row in the ListView.
// Tapping it opens AddTransactionScreen prefilled with this transaction's
// data, so the user can edit it. Saving there updates Hive + the provider,
// and this screen rebuilds automatically because it listens via Consumer.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
  });

  final TransactionModel transaction;

  // Shows a confirmation dialog before a swipe-to-delete is allowed to
  // complete. Dismissible calls this and waits for the Future<bool?> to
  // resolve: true lets the dismiss animation finish, anything else
  // (false or null, e.g. tapping outside the dialog) cancels it and the
  // tile slides back into place.
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: Text(
            'This will permanently delete "${transaction.title}". This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF168A4A) : const Color(0xFFD43D32);

    return Dismissible(
      // A stable, unique key lets Flutter correctly track this specific
      // tile across rebuilds even as items above/below it are added or removed.
      key: Key(transaction.id),

      // Only allow swiping right-to-left, the common convention for delete.
      direction: DismissDirection.endToStart,

      // Confirmation dialog runs first; the swipe only completes if the
      // user taps "Delete".
      confirmDismiss: (_) => _confirmDelete(context),

      // Red "delete" background revealed behind the tile while swiping.
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),

      // Fires only after confirmDismiss resolves to true.
      // Deletes from Hive + the provider's in-memory list, then
      // notifyListeners() refreshes the dashboard automatically.
      onDismissed: (_) {
        context.read<TransactionProvider>().deleteTransaction(transaction.id);
      },

      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          // Opens AddTransactionScreen in edit mode with this transaction
          // passed in, so the form is prefilled with its existing values.
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(
                  existingTransaction: transaction,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.14),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          title: Text(
            transaction.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          subtitle: Text(
            '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${isIncome ? 'Income' : 'Expense'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          // trailing now holds the amount AND a visible delete button.
          // The swipe-to-delete gesture from Dismissible still works too,
          // but a tappable icon is far more discoverable, especially on
          // web/desktop where dragging with a mouse is less intuitive
          // than swiping on a touchscreen.
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Delete',
                // Same confirmation dialog as the swipe gesture, then the
                // same delete call: Hive + provider + dashboard refresh.
                onPressed: () async {
                  final confirmed = await _confirmDelete(context);

                  if (confirmed == true) {
                    context
                        .read<TransactionProvider>()
                        .deleteTransaction(transaction.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
