import 'package:hive/hive.dart';

// Before using this file in your Flutter app, install these packages:
// flutter pub add hive hive_flutter
// flutter pub add --dev hive_generator build_runner
//
// After creating this file inside lib/models/, run:
// flutter pub run build_runner build
//
// That command generates transaction_model.g.dart, which contains the Hive adapter.
part 'transaction_model.g.dart';

// Hive needs a typeId for every custom type it stores.
// Keep this number unique in your whole app.
@HiveType(typeId: 0)
enum TransactionType {
  // HiveField numbers are the saved database positions.
  // Do not change them later after users have saved data.
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

// This model represents one income or expense record.
// It is immutable because all fields are final.
@HiveType(typeId: 1)
class TransactionModel {
  // A unique value for finding, updating, or deleting this transaction.
  @HiveField(0)
  final String id;

  // A short name shown in the UI, like Salary, Groceries, or Rent.
  @HiveField(1)
  final String title;

  // The money value. Use double because amounts can include decimals.
  @HiveField(2)
  final double amount;

  // The transaction date. Monthly summaries will filter using this field.
  @HiveField(3)
  final DateTime date;

  // Whether this transaction is income or expense.
  @HiveField(4)
  final TransactionType type;

  // Constructor used when creating a new transaction object.
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}
