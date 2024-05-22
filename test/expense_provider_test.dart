import 'package:expense_tracker_challenge/domain/entities/expense.dart';
import 'package:expense_tracker_challenge/domain/repositories/expense_repository.dart';
import 'package:expense_tracker_challenge/domain/usecases/add_expense.dart';
import 'package:expense_tracker_challenge/domain/usecases/delete_expense.dart';
import 'package:expense_tracker_challenge/domain/usecases/fetch_expenses.dart';
import 'package:expense_tracker_challenge/domain/usecases/update_expense.dart';
import 'package:expense_tracker_challenge/presentation/providers/expense_provider.dart';
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
  late ExpenseProvider expenseProvider;

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    addExpenseUseCase = AddExpense(mockExpenseRepository);
    fetchExpensesUseCase = FetchExpenses(mockExpenseRepository);
    updateExpenseUseCase = UpdateExpense(mockExpenseRepository);
    deleteExpenseUseCase = DeleteExpense(mockExpenseRepository);
    expenseProvider = ExpenseProvider(
      addExpenseUseCase: addExpenseUseCase,
      fetchExpensesUseCase: fetchExpensesUseCase,
      updateExpenseUseCase: updateExpenseUseCase,
      deleteExpenseUseCase: deleteExpenseUseCase,
    );
  });

  test('initially loads expenses', () async {
    // Stub fetchExpenses for this test
    when(mockExpenseRepository.fetchExpenses()).thenAnswer((_) async => []);

    await expenseProvider.loadExpenses();
    expect(expenseProvider.expenses, []);
    verify(mockExpenseRepository.fetchExpenses()).called(1);
  });

  test('adds an expense', () async {
    final expense = Expense(id: 1, description: 'Test', amount: 100.0, date: DateTime.now());

    // Stubs for this test
    when(mockExpenseRepository.addExpense(expense)).thenAnswer((_) async => null);
    when(mockExpenseRepository.fetchExpenses()).thenAnswer((_) async => [expense]);

    await expenseProvider.addExpense(expense);

    expect(expenseProvider.expenses, [expense]);
    verify(mockExpenseRepository.addExpense(expense)).called(1);
    verify(mockExpenseRepository.fetchExpenses()).called(2);
  });

  test('updates an expense', () async {
    final expense = Expense(id: 1, description: 'Test', amount: 100.0, date: DateTime.now());

    // Stubs for this test
    when(mockExpenseRepository.updateExpense(expense)).thenAnswer((_) async => null);
    when(mockExpenseRepository.fetchExpenses()).thenAnswer((_) async => [expense]);

    await expenseProvider.updateExpense(expense);

    expect(expenseProvider.expenses, [expense]);
    verify(mockExpenseRepository.updateExpense(expense)).called(1);
    verify(mockExpenseRepository.fetchExpenses()).called(2);
  });

  test('deletes an expense', () async {
    final expense = Expense(id: 1, description: 'Test', amount: 100.0, date: DateTime.now());

    // Stubs for this test
    when(mockExpenseRepository.deleteExpense(expense.id)).thenAnswer((_) async => null);
    when(mockExpenseRepository.fetchExpenses()).thenAnswer((_) async => []);

    await expenseProvider.deleteExpense(expense.id);

    expect(expenseProvider.expenses, []);
    verify(mockExpenseRepository.deleteExpense(expense.id)).called(1);
    verify(mockExpenseRepository.fetchExpenses()).called(2);
  });
}

