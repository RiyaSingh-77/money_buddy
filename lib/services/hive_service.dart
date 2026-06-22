//talks to hive, Keeps database code out of UI.
import 'package:hive/hive.dart';

import '../models/transaction_model.dart';

// This service is responsible only for Hive database work.
// Keeping database code here makes your screens and Provider cleaner.
class HiveService {
  // This is the name of the Hive box where all transactions will be stored.
  // Think of a Hive box like a small local database table on the phone.
  static const String transactionBoxName = 'transactions';

  // Opens the transaction box.
  // You should call this once when the app starts, usually in main.dart.
  Future<void> openTransactionBox() async {
    await Hive.openBox<TransactionModel>(transactionBoxName);
  }

  // Gets the already-opened transaction box.
  // This avoids repeating Hive.box<TransactionModel>('transactions') everywhere.
  Box<TransactionModel> get _transactionBox {
    return Hive.box<TransactionModel>(transactionBoxName);
  }

  // Adds a new transaction to Hive.
  // The transaction id is used as the key, so it is easy to update or delete later.
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  // Deletes a transaction from Hive using its id.
  // If the id does not exist, Hive simply has nothing to delete.
  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  // Updates an existing transaction.
  // Hive uses the id as the key, so put() replaces the old value with the new one.
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  // Gets all saved transactions from Hive.
  // The values are converted into a List so your Provider and UI can work with them easily.
  List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList();
  }
}