import 'package:expense_tracker_challenge/domain/entities/expense.dart';
import 'package:expense_tracker_challenge/domain/repositories/expense_repository.dart';
import 'package:expense_tracker_challenge/domain/usecases/add_expense.dart';
import 'package:expense_tracker_challenge/domain/usecases/delete_expense.dart';
import 'package:expense_tracker_challenge/domain/usecases/fetch_expenses.dart';
import 'package:expense_tracker_challenge/domain/usecases/update_expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'expense_provider_test.mocks.dart';

@GenerateMocks([ExpenseRepository])
void main() {
  late MockExpenseRepository mockExpenseRepository;
  late AddExpense addExpenseUseCase;
  late FetchExpenses fetchExpensesUseCase;
  late UpdateExpense updateExpenseUseCase;
  late DeleteExpense deleteExpenseUseCase;

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    addExpenseUseCase = AddExpense(mockExpenseRepository);
    fetchExpensesUseCase = FetchExpenses(mockExpenseRepository);
    updateExpenseUseCase = UpdateExpense(mockExpenseRepository);
    deleteExpenseUseCase = DeleteExpense(mockExpenseRepository);
  });

  final expense = Expense(
      id: 1,
      description: 'Test',
      amount: 100.0,
      date: DateTime.now(),
      type: 'Food');

  test('AddExpense use case', () async {
    when(mockExpenseRepository.addExpense(expense))
        .thenAnswer((_) async => null);

    await addExpenseUseCase(expense);

    verify(mockExpenseRepository.addExpense(expense)).called(1);
  });

  test('FetchExpenses use case', () async {
    when(mockExpenseRepository.fetchExpenses())
        .thenAnswer((_) async => [expense]);

    final result = await fetchExpensesUseCase();

    expect(result, [expense]);
    verify(mockExpenseRepository.fetchExpenses()).called(1);
  });

  test('UpdateExpense use case', () async {
    when(mockExpenseRepository.updateExpense(expense))
        .thenAnswer((_) async => null);

    await updateExpenseUseCase(expense);

    verify(mockExpenseRepository.updateExpense(expense)).called(1);
  });

  test('DeleteExpense use case', () async {
    when(mockExpenseRepository.deleteExpense(expense.id))
        .thenAnswer((_) async => null);

    await deleteExpenseUseCase(expense.id);

    verify(mockExpenseRepository.deleteExpense(expense.id)).called(1);
  });
}
