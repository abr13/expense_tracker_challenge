import 'package:flutter/material.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/fetch_expenses.dart';
import '../../domain/usecases/update_expense.dart';

class ExpenseProvider with ChangeNotifier {
  final AddExpense addExpenseUseCase;
  final FetchExpenses fetchExpensesUseCase;
  final UpdateExpense updateExpenseUseCase;
  final DeleteExpense deleteExpenseUseCase;

  ExpenseProvider({
    required this.addExpenseUseCase,
    required this.fetchExpensesUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) {
    loadExpenses();
  }

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  Future<void> addExpense(Expense expense) async {
    await addExpenseUseCase(expense);
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    _expenses = await fetchExpensesUseCase();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await updateExpenseUseCase(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await deleteExpenseUseCase(id);
    await loadExpenses();
  }
}

