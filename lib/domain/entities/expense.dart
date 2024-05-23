class Expense {
  final int id;
  final String description;
  final double amount;
  final DateTime date;
  final String type;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
}
