import 'package:expense_tracker_challenge/presentation/providers/expense_provider.dart';
import 'package:expense_tracker_challenge/presentation/screens/expense_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'data/datasources/expense_local_data_source.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/usecases/add_expense.dart';
import 'domain/usecases/delete_expense.dart';
import 'domain/usecases/fetch_expenses.dart';
import 'domain/usecases/update_expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final expenseLocalDataSource = ExpenseLocalDataSource.instance;
  final expenseRepository = ExpenseRepositoryImpl(expenseLocalDataSource);

  final MyApp app = MyApp(
    expenseProvider: ExpenseProvider(
      addExpenseUseCase: AddExpense(expenseRepository),
      fetchExpensesUseCase: FetchExpenses(expenseRepository),
      updateExpenseUseCase: UpdateExpense(expenseRepository),
      deleteExpenseUseCase: DeleteExpense(expenseRepository),
    ),
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  );

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await app.showInitialNotification();

  runApp(app);

  app.scheduleReminder();
}

class MyApp extends StatelessWidget {
  final ExpenseProvider expenseProvider;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyApp({
    super.key,
    required this.expenseProvider,
    required this.flutterLocalNotificationsPlugin,
  });

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
        home: const ExpenseListScreen(),
      ),
    );
  }

  Future<void> scheduleReminder() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'reminder_1',
      'Expense tracker',
      channelDescription: 'Simple expense tracker',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Record Daily Expense',
        'Remember to record your daily expenses.',
        RepeatInterval.daily,
        platformChannelSpecifics);
  }

  Future<void> showInitialNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'reminder_2',
      'Expense tracker',
      channelDescription: 'Simple expense tracker',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Welcome to Expense Tracker',
        'Start tracking your expenses today!', platformChannelSpecifics);
  }
}
