import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late double _amount;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _description = widget.expense!.description;
      _amount = widget.expense!.amount;
      _date = widget.expense!.date;
    } else {
      _description = '';
      _amount = 0;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Colors.lightBlue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _amount != 0 ? _amount.toString() : '',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "100",
                ),
                style: const TextStyle(color: Colors.black87),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
                textCapitalization: TextCapitalization.sentences,
                autofocus: false,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _date = selectedDate;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Select Date: ${DateFormat('dd/MM/yyyy').format(_date)}',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[700],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final newExpense = Expense(
                      id: widget.expense?.id ??
                          DateTime.now().millisecondsSinceEpoch,
                      description: _description,
                      amount: _amount,
                      date: _date,
                    );

                    if (widget.expense != null) {
                      await expenseProvider.updateExpense(newExpense);
                    } else {
                      await expenseProvider.addExpense(newExpense);
                    }

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.expense != null ? Colors.orange : Colors.green,
                ),
                child: Text(
                  widget.expense != null ? 'Update' : 'Add',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
