//This is where you keep the current list of income and expense records, add new items, delete items, and calculate summaries
import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../services/hive_service.dart';


// ChangeNotifier is a Flutter class that lets this provider tell the UI:
// "My data changed, please rebuild the widgets that are listening."
class TransactionProvider extends ChangeNotifier {
  // The HiveService handles database work.
  // This provider handles app state and tells the UI when that state changes.
  final HiveService _hiveService;

  // This private list is the provider's in-memory copy of all transactions.
  // The underscore means other files cannot edit it directly.
  List<TransactionModel> _transactions = [];

  // The provider receives HiveService here.
  // If no service is passed, it creates one automatically.
  TransactionProvider({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService();

  // This public getter lets screens read transactions safely.
  // List.unmodifiable prevents UI code from accidentally changing the list directly.
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  // Loads saved transactions from Hive into the provider's in-memory list.
  // Call this after opening the Hive box, usually when the app starts.
  void loadTransactions() {
    _transactions = _hiveService.getAllTransactions();

    // notifyListeners() tells all listening widgets to rebuild with the latest data.
    notifyListeners();
  }

  // Adds a new transaction to Hive and then updates the provider list.
  Future<void> addTransaction(TransactionModel transaction) async {
    await _hiveService.addTransaction(transaction);

    _transactions.add(transaction);

    // Without this, the data would change but the screen would not refresh automatically.
    notifyListeners();
  }

  // Deletes a transaction from Hive and removes it from the provider list.
  Future<void> deleteTransaction(String id) async {
    await _hiveService.deleteTransaction(id);

    _transactions.removeWhere((transaction) => transaction.id == id);

    notifyListeners();
  }

  // Updates a transaction in Hive and replaces the old item in the provider list.
  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    await _hiveService.updateTransaction(updatedTransaction);

    final index = _transactions.indexWhere(
      (transaction) => transaction.id == updatedTransaction.id,
    );

    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }
}
