import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
class Person extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String userId;

  Person({
    required this.name,
    required this.phoneNumber,
    this.userId = '',
  });
}