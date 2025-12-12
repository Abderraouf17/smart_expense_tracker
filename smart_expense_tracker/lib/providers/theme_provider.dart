import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en';
  String _currency = 'SAR';

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
    _currency = box.get('currency', defaultValue: 'SAR');
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
    // For Arabic language, use Arabic symbols regardless of currency type
    if (_language == 'ar') {
      switch (_currency) {
        case 'SAR':
          return 'ر.س';
        case 'DZD':
          return 'د.ج';
        case 'MAD':
          return 'د.م';
        case 'EUR':
          return 'يورو';
        case 'GBP':
          return 'جنيه';
        case 'JPY':
          return 'ين';
        case 'USD':
          return 'دولار';
        default:
          return 'ر.س';
      }
    }
    // For English language, use standard symbols
    switch (_currency) {
      case 'SAR':
        return 'SAR';
      case 'DZD':
        return 'DZD';
      case 'MAD':
        return 'MAD';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'USD':
        return '\$';
      default:
        return '\$';
    }
  }
}
