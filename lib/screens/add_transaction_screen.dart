import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';


// AddTransactionScreen is StatefulWidget because the form fields, dropdown,
// and selected date change while the user is filling the form.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // The form key gives us access to the Form's current state.
  // We use it to run validation before saving the transaction.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController lets us read and control the text typed by the user.
  // This controller stores the title input value.
  final _titleController = TextEditingController();

  // This controller stores the amount input value.
  final _amountController = TextEditingController();

  // The dropdown starts with expense selected because users usually add expenses more often.
  TransactionType _selectedType = TransactionType.expense;

  // The date picker starts with today's date.
  DateTime _selectedDate = DateTime.now();

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
      // DateTime.now().microsecondsSinceEpoch gives a simple unique id for learning projects.
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      type: _selectedType,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);

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
        title: const Text('Add Transaction'),
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
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
