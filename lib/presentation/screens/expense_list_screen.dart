import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

enum SortOption {
  ByDateAscending,
  ByDateDescending,
}

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  SortOption _sortOption = SortOption.ByDateDescending;
  late DateTime _selectedDate;
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    List<Expense> sortedExpenses = _sortExpenses(expenseProvider.expenses);

    if (_isFiltering) {
      sortedExpenses = _filterExpenses(expenseProvider.expenses);
    }

    Map<String, double> summaries =
        _calculateSummaries(expenseProvider.expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (option) {
              setState(() {
                _sortOption = option;
                sortedExpenses = _sortExpenses(expenseProvider.expenses);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.ByDateDescending,
                child: Text('Sort by Date (Newest First)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.ByDateAscending,
                child: Text('Sort by Date (Oldest First)'),
              ),
            ],
          ),
          IconButton(
            icon: _isFiltering
                ? const Icon(Icons.filter_alt)
                : const Icon(Icons.filter_alt_outlined),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  _isFiltering = true;
                });
              }
            },
          ),
          if (_isFiltering)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isFiltering = false;
                  sortedExpenses = _sortExpenses(expenseProvider.expenses);
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isFiltering
                  ? 'Filtered Expenses for ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'
                  : 'All Expenses',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryChart(summaries),
            const SizedBox(height: 16),
            Expanded(
              child: sortedExpenses.isEmpty
                  ? Center(
                      child: Text(
                        'No expenses found',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = sortedExpenses[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              expense.description,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '₹${expense.amount.toStringAsFixed(2)} - ${DateFormat('dd/MM/yyyy hh:mm a').format(expense.date.toLocal())}',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddExpenseScreen(expense: expense),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(expense.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Expense> _sortExpenses(List<Expense> expenses) {
    switch (_sortOption) {
      case SortOption.ByDateAscending:
        return expenses.toList()..sort((a, b) => a.date.compareTo(b.date));
      case SortOption.ByDateDescending:
        return expenses.toList()..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses
        .where((expense) =>
            _selectedDate.year == expense.date.year &&
            _selectedDate.month == expense.date.month &&
            _selectedDate.day == expense.date.day)
        .toList();
  }

  Map<String, double> _calculateSummaries(List<Expense> expenses) {
    Map<String, double> summaries = {};

    for (Expense expense in expenses) {
      summaries[expense.type] = (summaries[expense.type] ?? 0) + expense.amount;
    }

    return summaries;
  }

  Widget _buildSummaryChart(Map<String, double> summaries) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: summaries.entries.map((entry) {
            final color = _getTypeColor(entry.key);
            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '${entry.key}\n₹${entry.value.toStringAsFixed(0)}',
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 4,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Food':
        return Colors.blue;
      case 'Transport':
        return Colors.green;
      case 'Shopping':
        return Colors.orange;
      case 'Entertainment':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmationDialog(int expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ExpenseProvider>(context, listen: false)
                    .deleteExpense(expenseId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
