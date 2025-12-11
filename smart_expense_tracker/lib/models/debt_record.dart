import 'package:hive/hive.dart';

part 'debt_record.g.dart';

@HiveType(typeId: 2)
class DebtRecord extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String type; // 'debt' or 'payback'

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String note;

  @HiveField(4)
  String personId;

  @HiveField(5)
  String userId;

  DebtRecord({
    required this.amount,
    required this.type,
    required this.date,
    required this.note,
    required this.personId,
    this.userId = '',
  });
}