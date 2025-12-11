import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en';
  String _currency = 'USD';

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  String get currency => _currency;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    await Hive.openBox('settings');
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box('settings');
    _isDarkMode = box.get('darkMode', defaultValue: false);
    _language = box.get('language', defaultValue: 'en');
    _currency = box.get('currency', defaultValue: 'USD');
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    final box = Hive.box('settings');
    box.put('darkMode', _isDarkMode);
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    final box = Hive.box('settings');
    box.put('language', language);
    notifyListeners();
  }

  void setCurrency(String currency) {
    _currency = currency;
    final box = Hive.box('settings');
    box.put('currency', currency);
    notifyListeners();
  }

  String getCurrencySymbol() {
    switch (_currency) {
      case 'SAR': return 'ر.س';
      case 'DZD': return 'د.ج';
      case 'MAD': return 'د.م';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      default: return '\$';
    }
  }
}