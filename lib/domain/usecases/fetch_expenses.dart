
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class FetchExpenses {
  final ExpenseRepository repository;

  FetchExpenses(this.repository);

  Future<List<Expense>> call() async {
    return await repository.fetchExpenses();
  }
}
