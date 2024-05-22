import 'package:expense_tracker_challenge/presentation/providers/expense_provider.dart';
import 'package:expense_tracker_challenge/presentation/screens/expense_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/expense_local_data_source.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/usecases/add_expense.dart';
import 'domain/usecases/delete_expense.dart';
import 'domain/usecases/fetch_expenses.dart';
import 'domain/usecases/update_expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final expenseLocalDataSource = ExpenseLocalDataSource.instance;
  final expenseRepository = ExpenseRepositoryImpl(expenseLocalDataSource);

  runApp(MyApp(
    expenseProvider: ExpenseProvider(
      addExpenseUseCase: AddExpense(expenseRepository),
      fetchExpensesUseCase: FetchExpenses(expenseRepository),
      updateExpenseUseCase: UpdateExpense(expenseRepository),
      deleteExpenseUseCase: DeleteExpense(expenseRepository),
    ),
  ));
}

class MyApp extends StatelessWidget {
  final ExpenseProvider expenseProvider;

  MyApp({required this.expenseProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => expenseProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Personal Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ExpenseListScreen(),
      ),
    );
  }
}
