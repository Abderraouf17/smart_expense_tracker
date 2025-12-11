import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
  ];

  // Common
  String get appTitle => locale.languageCode == 'ar' ? 'متتبع المصروفات' : 'Expense Tracker';
  String get hello => locale.languageCode == 'ar' ? 'مرحباً' : 'Hello';
  String get save => locale.languageCode == 'ar' ? 'حفظ' : 'Save';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get delete => locale.languageCode == 'ar' ? 'حذف' : 'Delete';
  String get add => locale.languageCode == 'ar' ? 'إضافة' : 'Add';

  // Home
  String get balance => locale.languageCode == 'ar' ? 'الرصيد' : 'Balance';
  String get income => locale.languageCode == 'ar' ? 'الدخل' : 'Income';
  String get expenses => locale.languageCode == 'ar' ? 'المصروفات' : 'Expenses';
  String get spendingTrends => locale.languageCode == 'ar' ? 'اتجاهات الإنفاق' : 'Spending Trends Chart';

  // Profile
  String get profile => locale.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile';
  String get darkMode => locale.languageCode == 'ar' ? 'الوضع المظلم' : 'Dark Mode';
  String get language => locale.languageCode == 'ar' ? 'اللغة' : 'Language';
  String get currency => locale.languageCode == 'ar' ? 'العملة' : 'Currency';
  String get signOut => locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Sign Out';

  // Form fields
  String get name => locale.languageCode == 'ar' ? 'الاسم' : 'Name';
  String get email => locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get amount => locale.languageCode == 'ar' ? 'المبلغ' : 'Amount';
  String get category => locale.languageCode == 'ar' ? 'الفئة' : 'Category';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}