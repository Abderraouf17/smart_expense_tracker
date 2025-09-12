import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _category;
  String? _note;
  String _currency = 'USD';
  DateTime _selectedDate = DateTime.now();

  final List<String> _currencies = ['USD', 'SAR', 'DZD', 'EUR'];
  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Other'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newExpense = Expense(
        amount: _amount!,
        category: _category!,
        note: _note ?? '',
        date: _selectedDate,
        currency: _currency,
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(newExpense);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                onSaved: (value) => _amount = double.tryParse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (val) => setState(() => _category = val),
                validator: (value) => value == null ? 'Select category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                onSaved: (value) => _note = value,
              ),
              DropdownButtonFormField<String>(
                value: _currency,
                items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                decoration: const InputDecoration(labelText: 'Currency'),
                onChanged: (val) => setState(() => _currency = val!),
              ),
              ListTile(
                title: Text('Date: ${DateFormat.yMd().format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
