import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../models/income_source.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<IncomeSource> _incomeSources = [];
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final Box<IncomeSource> _incomeSourceBox = Hive.box<IncomeSource>('income_sources');
  final Box _settingsBox = Hive.box('settings');
  String? _currentUserId;

  List<Expense> get expenses => _expenses;
  List<IncomeSource> get incomeSources => _incomeSources;

  double get totalSpent {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  // Monthly salary only
  double get monthlySalary {
    if (_currentUserId == null) return 0.0;
    return _settingsBox.get('salary_$_currentUserId', defaultValue: 0.0);
  }

  // Total from other income sources
  double get otherIncomesTotal {
    return _incomeSources.fold(0, (sum, item) => sum + item.amount);
  }

  // Total income = salary + other incomes
  double get totalIncome {
    return monthlySalary + otherIncomesTotal;
  }

  // Set monthly salary
  void setMonthlySalary(double salary) {
    if (_currentUserId != null) {
      _settingsBox.put('salary_$_currentUserId', salary);
      notifyListeners();
    }
  }

  // Balance limit management
  double? get balanceLimit {
    if (_currentUserId == null) return null;
    return _settingsBox.get('balance_limit_$_currentUserId');
  }

  void setBalanceLimit(double? limit) {
    if (_currentUserId != null) {
      if (limit == null) {
        _settingsBox.delete('balance_limit_$_currentUserId');
      } else {
        _settingsBox.put('balance_limit_$_currentUserId', limit);
      }
      notifyListeners();
    }
  }

  bool checkBalanceLimitReached() {
    final limit = balanceLimit;
    if (limit == null) return false;
    return balance <= limit;
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
    loadIncomeSources();
  }

  Future<void> loadExpenses() async {
    if (_currentUserId == null) {
      _expenses = [];
    } else {
      _expenses = _expenseBox.values
          .where((expense) => expense.userId == _currentUserId)
          .toList();
    }
    notifyListeners();
  }

  Future<void> loadIncomeSources() async {
    if (_currentUserId == null) {
      _incomeSources = [];
    } else {
      _incomeSources = _incomeSourceBox.values
          .where((source) => source.userId == _currentUserId)
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

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
    await loadExpenses();
  }

  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
    await loadExpenses();
  }

  // Income source management
  Future<void> addIncomeSource(IncomeSource source) async {
    if (_currentUserId != null) {
      source.userId = _currentUserId!;
      await _incomeSourceBox.add(source);
      await loadIncomeSources();
    }
  }

  Future<void> updateIncomeSource(IncomeSource source) async {
    await source.save();
    await loadIncomeSources();
  }

  Future<void> deleteIncomeSource(IncomeSource source) async {
    await source.delete();
    await loadIncomeSources();
  }

  void clearAll() async {
    if (_currentUserId != null) {
      // Clear expenses
      final userExpenses = _expenseBox.values
          .where((expense) => expense.userId == _currentUserId)
          .toList();
      for (final expense in userExpenses) {
        await expense.delete();
      }
      
      // Clear income sources
      final userSources = _incomeSourceBox.values
          .where((source) => source.userId == _currentUserId)
          .toList();
      for (final source in userSources) {
        await source.delete();
      }
      
      await loadExpenses();
      await loadIncomeSources();
    }
  }
}
