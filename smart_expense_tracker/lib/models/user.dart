import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class AppUser extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password;

  AppUser({required this.username, required this.password});
}
