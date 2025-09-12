import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');

  List<Expense> get expenses => _expenses;

  double get totalSpent {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> loadExpenses() async {
    _expenses = _expenseBox.values.toList();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseBox.add(expense);
    _expenses = _expenseBox.values.toList();
    notifyListeners();
  }

  Future<void> deleteExpense(int index) async {
    await _expenseBox.deleteAt(index);
    _expenses = _expenseBox.values.toList();
    notifyListeners();
  }

  void clearAll() async {
    await _expenseBox.clear();
    _expenses.clear();
    notifyListeners();
  }
}
