import 'package:hive/hive.dart';

part 'income_source.g.dart';

@HiveType(typeId: 3)
class IncomeSource extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String type; // 'Freelance', 'Business', etc.

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String userId;

  IncomeSource({
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.userId = '',
  });
}
