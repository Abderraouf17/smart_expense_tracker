import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    await Hive.openBox('settings');
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box('settings');
    _isDarkMode = box.get('darkMode', defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    final box = Hive.box('settings');
    box.put('darkMode', _isDarkMode);
    notifyListeners();
  }
}
