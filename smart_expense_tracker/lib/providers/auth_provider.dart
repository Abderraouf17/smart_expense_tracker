import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  final _userBox = Hive.box<AppUser>('users');
  final _settingsBox = Hive.box('settings');

  AuthProvider() {
    _loadUser();
  }

  void _loadUser() {
    final userKey = _settingsBox.get('loggedInUserKey');
    if (userKey != null && _userBox.containsKey(userKey)) {
      _currentUser = _userBox.get(userKey);
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    final user = _userBox.values.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => throw Exception('Invalid credentials'),
    );
    _currentUser = user;
    await _settingsBox.put('loggedInUserKey', user.key);
    notifyListeners();
  }

  Future<void> signup(String username, String password) async {
    final exists = _userBox.values.any((u) => u.username == username);
    if (exists) throw Exception('User already exists');

    final newUser = AppUser(username: username, password: password);
    final userKey = await _userBox.add(newUser);
    _currentUser = newUser;
    await _settingsBox.put('loggedInUserKey', userKey);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _settingsBox.delete('loggedInUserKey');
    notifyListeners();
  }

  Future<List<AppUser>> getAllUsers() async {
    return _userBox.values.toList();
  }
}
