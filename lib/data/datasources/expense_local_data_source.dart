import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  static final ExpenseLocalDataSource instance = ExpenseLocalDataSource._init();
  static Database? _database;

  ExpenseLocalDataSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL
    )
    ''');
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> fetchExpenses() async {
    final db = await instance.database;
    final maps = await db.query('expenses');
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await instance.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await instance.database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

