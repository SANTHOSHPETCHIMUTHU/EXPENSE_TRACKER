import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/group_expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<GroupExpense> _groupExpenses = [];
  double _savings = 0.0;
  double _budget = 0.0;

  static const String _expensesKey = 'expenses';
  static const String _groupExpensesKey = 'group_expenses';
  static const String _savingsKey = 'savings';
  static const String _budgetKey = 'budget';

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<GroupExpense> get groupExpenses => List.unmodifiable(_groupExpenses);
  double get savings => _savings;
  double get budget => _budget;
  double get totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get totalGroupExpenses =>
      _groupExpenses.fold(0, (sum, e) => sum + e.totalAmount);
  double get remainingBudget => _budget - totalExpenses - totalGroupExpenses;

  ExpenseProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load individual expenses
    final expensesJson = prefs.getStringList(_expensesKey) ?? [];
    _expenses.clear();
    _expenses.addAll(
      expensesJson.map((json) => Expense.fromJson(jsonDecode(json))),
    );

    // Load group expenses
    final groupExpensesJson = prefs.getStringList(_groupExpensesKey) ?? [];
    _groupExpenses.clear();
    _groupExpenses.addAll(
      groupExpensesJson.map((json) => GroupExpense.fromJson(jsonDecode(json))),
    );

    // Load savings and budget
    _savings = prefs.getDouble(_savingsKey) ?? 0.0;
    _budget = prefs.getDouble(_budgetKey) ?? 0.0;

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save individual expenses
    final expensesJson =
        _expenses.map((expense) => jsonEncode(expense.toJson())).toList();
    await prefs.setStringList(_expensesKey, expensesJson);

    // Save group expenses
    final groupExpensesJson =
        _groupExpenses.map((expense) => jsonEncode(expense.toJson())).toList();
    await prefs.setStringList(_groupExpensesKey, groupExpensesJson);

    // Save savings and budget
    await prefs.setDouble(_savingsKey, _savings);
    await prefs.setDouble(_budgetKey, _budget);
  }

  void setSavings(double amount) {
    _savings = amount;
    _saveData();
    notifyListeners();
  }

  void setBudget(double amount) {
    _budget = amount;
    _saveData();
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveData();
    notifyListeners();
  }

  void addGroupExpense(GroupExpense expense) {
    _groupExpenses.add(expense);
    _saveData();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveData();
    notifyListeners();
  }

  void deleteGroupExpense(String id) {
    _groupExpenses.removeWhere((expense) => expense.id == id);
    _saveData();
    notifyListeners();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) {
      return expense.date.isAfter(start) && expense.date.isBefore(end);
    }).toList();
  }

  List<GroupExpense> getGroupExpensesByDateRange(DateTime start, DateTime end) {
    return _groupExpenses.where((expense) {
      return expense.date.isAfter(start) && expense.date.isBefore(end);
    }).toList();
  }

  Map<ExpenseCategory, double> getCategoryTotals() {
    final Map<ExpenseCategory, double> totals = {};
    for (var category in ExpenseCategory.values) {
      totals[category] = _expenses
          .where((expense) => expense.category == category)
          .fold(0, (sum, expense) => sum + expense.amount);
    }
    return totals;
  }

  void resetAllData() {
    _expenses.clear();
    _groupExpenses.clear();
    _budget = 0.0;
    notifyListeners();
  }
}
