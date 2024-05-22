
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> fetchExpenses();
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);
}
