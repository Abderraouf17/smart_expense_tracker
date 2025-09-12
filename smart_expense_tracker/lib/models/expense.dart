import 'package:hive/hive.dart';

part 'expense.g.dart'; // Needed for Hive code generation

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String category;

  @HiveField(2)
  String note;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String currency;

  Expense({
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.currency,
  });
}
