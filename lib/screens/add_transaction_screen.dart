import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';


// AddTransactionScreen is StatefulWidget because the form fields, dropdown,
// and selected date change while the user is filling the form.
//
// This screen now works for BOTH adding a new transaction and editing an
// existing one. Pass `existingTransaction` to open it in edit mode:
// the form will be prefilled and saving will update the existing record
// instead of creating a new one.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.existingTransaction});

  // When this is null, the screen behaves as "Add Transaction".
  // When it is not null, the screen behaves as "Edit Transaction".
  final TransactionModel? existingTransaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // The form key gives us access to the Form's current state.
  // We use it to run validation before saving the transaction.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController lets us read and control the text typed by the user.
  // This controller stores the title input value.
  late final TextEditingController _titleController;

  // This controller stores the amount input value.
  late final TextEditingController _amountController;

  // The dropdown starts with expense selected because users usually add expenses more often,
  // unless we are editing a transaction, in which case we prefill its actual type.
  late TransactionType _selectedType;

  // The date picker starts with today's date, unless we are editing a transaction,
  // in which case we prefill its actual date.
  late DateTime _selectedDate;

  // Convenience getter so the build method and _saveTransaction can both
  // easily check whether we are editing or adding.
  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingTransaction;

    // Prefill every field from the existing transaction when editing.
    // When adding, fall back to the original sensible defaults.
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toString() : '',
    );
    _selectedType = existing?.type ?? TransactionType.expense;
    _selectedDate = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    // Controllers use memory, so we dispose them when the screen is removed.
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // showDatePicker opens Flutter's built-in calendar picker.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    // If the user cancels the picker, pickedDate will be null.
    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _saveTransaction() async {
    // validate() runs every validator inside the Form.
    // If any field returns an error message, the form is not valid.
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    final transaction = TransactionModel(
      // Reuse the original id when editing so Hive's put() overwrites the
      // same record instead of creating a brand new one.
      // DateTime.now().microsecondsSinceEpoch gives a simple unique id for new transactions.
      id: widget.existingTransaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      type: _selectedType,
    );

    final provider = context.read<TransactionProvider>();

    if (_isEditing) {
      // Updates Hive and the provider's in-memory list, then notifyListeners()
      // inside the provider refreshes the dashboard automatically.
      await provider.updateTransaction(transaction);
    } else {
      await provider.addTransaction(transaction);
    }

    if (!mounted) {
      return;
    }

    // After saving, close this screen and return to the previous screen.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          // Form groups input fields and allows validation using _formKey.
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TextFormField is a text input that works with Form validation.
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null) {
                      return 'Please enter a valid number';
                    }

                    if (amount <= 0) {
                      return 'Amount must be greater than zero';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // DropdownButtonFormField gives a dropdown that also fits nicely inside a Form.
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text('Income'),
                    ),
                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text('Expense'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // OutlinedButton is used here because picking a date is an action,
                // not a typed text field.
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
                const SizedBox(height: 24),

                // ElevatedButton is the main action button for saving the form.
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
