import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl(this.localDataSource);

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel(
      id: expense.id,
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
    );
    await localDataSource.addExpense(model);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Future<List<Expense>> fetchExpenses() async {
    final models = await localDataSource.fetchExpenses();
    return models.map((model) => Expense(
      id: model.id,
      description: model.description,
      amount: model.amount,
      date: model.date,
    )).toList();
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel(
      id: expense.id,
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
    );
    await localDataSource.updateExpense(model);
  }
}

