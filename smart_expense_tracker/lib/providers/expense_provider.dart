import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final Box _settingsBox = Hive.box('settings');
  String? _currentUserId;

  List<Expense> get expenses => _expenses;

  double get totalSpent {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    if (_currentUserId == null) return 0.0;
    return _settingsBox.get('income_$_currentUserId', defaultValue: 0.0);
  }

  void setIncome(double income) {
    if (_currentUserId != null) {
      _settingsBox.put('income_$_currentUserId', income);
      notifyListeners();
    }
  }

  double get balance {
    return totalIncome - totalSpent;
  }

  double get totalSpentThisMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    return _expenses
        .where((expense) => expense.date.isAfter(thisMonth.subtract(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get totalSpentToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _expenses
        .where((expense) => 
            expense.date.year == today.year &&
            expense.date.month == today.month &&
            expense.date.day == today.day)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(_expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    if (_currentUserId == null) {
      _expenses = [];
    } else {
      // Load expenses for current user only
      _expenses = _expenseBox.values
          .where((expense) => expense.userId == _currentUserId)
          .toList();
    }
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    if (_currentUserId != null) {
      expense.userId = _currentUserId!;
      await _expenseBox.add(expense);
      await loadExpenses();
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
    await loadExpenses();
  }

  void clearAll() async {
    if (_currentUserId != null) {
      // Only clear expenses for current user
      final userExpenses = _expenseBox.values
          .where((expense) => expense.userId == _currentUserId)
          .toList();
      for (final expense in userExpenses) {
        await expense.delete();
      }
      await loadExpenses();
    }
  }
}
