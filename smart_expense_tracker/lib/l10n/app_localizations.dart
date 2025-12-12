import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  // Common
  String get appTitle => isArabic ? 'تراك إت' : 'Trackit';
  String get hello => isArabic ? 'مرحباً' : 'Hello';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get saving => isArabic ? 'جار الحفظ' : 'Saving';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get add => isArabic ? 'إضافة' : 'Add';
  String get adding => isArabic ? 'جار الإضافة' : 'Adding';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';
  String get update => isArabic ? 'تحديث' : 'Update';
  String get setting => isArabic ? 'جار التعيين' : 'Setting';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get apply => isArabic ? 'تطبيق' : 'Apply';
  String get arabic => 'العربية';
  String get english => 'English';

  // Auth
  String get welcomeBack => isArabic ? 'مرحباً بعودتك' : 'Welcome Back';
  String get manageFinances =>
      isArabic ? 'أدر أموالك بذكاء' : 'Manage your finances smartly';
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get createAccount => isArabic ? 'إنشاء حساب' : 'Create Account';
  String get rememberMe => isArabic ? 'تذكرني' : 'Remember Me';
  String get joinUs =>
      isArabic ? 'انضم إلينا وابدأ التوفير' : 'Join us and start saving';
  String get signUp => isArabic ? 'تسجيل' : 'Sign Up';
  String get seeFeatures =>
      isArabic ? 'شاهد مميزات النظام' : 'See System Features';
  String get whyApp =>
      isArabic ? 'لماذا متتبع المصروفات الذكي؟' : 'Why Smart Expense Tracker?';
  String get enterEmailPassword => isArabic
      ? 'الرجاء إدخال البريد الإلكتروني وكلمة المرور'
      : 'Please enter email and password';
  String get loginFailed => isArabic ? 'فشل تسجيل الدخول' : 'Login failed';
  String get noUserFound =>
      isArabic ? 'لم يتم العثور على مستخدم' : 'No user found for that email';
  String get wrongPassword =>
      isArabic ? 'كلمة المرور خاطئة' : 'Wrong password provided';
  String get invalidCredentials =>
      isArabic ? 'البيانات غير صحيحة' : 'Invalid email or password';

  // Features
  String get smartAnalytics => isArabic ? 'تحليلات ذكية' : 'Smart Analytics';
  String get smartAnalyticsDesc => isArabic
      ? 'تخيل عادات إنفاقك برسوم بيانية بديهية.'
      : 'Visualize your spending habits with intuitive charts and graphs.';
  String get expenseTracking =>
      isArabic ? 'تتبع المصروفات' : 'Expense Tracking';
  String get expenseTrackingDesc => isArabic
      ? 'سجل وصنف نفقاتك اليومية بسهولة.'
      : 'Easily record and categorize your daily expenses.';
  String get debtManagement => isArabic ? 'إدارة الديون' : 'Debt Management';
  String get debtManagementDesc => isArabic
      ? 'تتبع من يدين لك ومن تدين له.'
      : 'Keep track of who owes you and who you owe.';
  String get cloudSync => isArabic ? 'مزامنة سحابية' : 'Cloud Sync';
  String get cloudSyncDesc => isArabic
      ? 'بياناتك محفوظة بأمان في السحابة.'
      : 'Your data is securely backed up to the cloud.';
  String get darkModeFeature => isArabic ? 'الوضع المظلم' : 'Dark Mode';
  String get darkModeFeatureDesc => isArabic
      ? 'مريح لعينيك مع دعم الوضع المظلم.'
      : 'Easy on your eyes with built-in dark mode support.';

  // Home
  String get balance => isArabic ? 'الرصيد' : 'Balance';
  String get income => isArabic ? 'الدخل' : 'Income';
  String get totalSpent => isArabic ? 'إجمالي المصروفات' : 'Total Spent';
  String get spendingTrends => isArabic ? 'اتجاهات الإنفاق' : 'Spending Trends';
  String get recentExpenses => isArabic ? 'أحدث المصروفات' : 'Recent Expenses';
  String get noExpenses => isArabic ? 'لا توجد مصروفات بعد' : 'No expenses yet';
  String get thisMonth => isArabic ? 'هذا الشهر' : 'This Month';
  String get today => isArabic ? 'اليوم' : 'Today';
  String get avg => isArabic ? 'المعدل' : 'Avg';
  String get day => isArabic ? 'يوم' : 'day';
  String get month => isArabic ? 'شهر' : 'mo';
  String get spentToday => isArabic ? 'أنفقت اليوم' : 'Spent today';

  // Profile
  String get profile => isArabic ? 'الملف الشخصي' : 'Profile';
  String get darkMode => isArabic ? 'الوضع المظلم' : 'Dark Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get currency => isArabic ? 'العملة' : 'Currency';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  String get profileInfo =>
      isArabic ? 'معلومات الملف الشخصي' : 'Profile Information';
  String get changePassword =>
      isArabic ? 'تغيير كلمة المرور' : 'Change Password';
  String get currentPassword =>
      isArabic ? 'كلمة المرور الحالية' : 'Current Password';
  String get newPassword => isArabic ? 'كلمة المرور الجديدة' : 'New Password';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get updateProfile =>
      isArabic ? 'تحديث الملف الشخصي' : 'Update Profile';

  // Form fields
  String get name => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get confirmPassword =>
      isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get amount => isArabic ? 'المبلغ' : 'Amount';
  String get category => isArabic ? 'الفئة' : 'Category';
  String get notes => isArabic ? 'ملاحظات (اختياري)' : 'Notes (Optional)';
  String get phoneNumber => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get selectPerson => isArabic ? 'اختر شخصاً' : 'Select Person';
  String get enterAmountCategory => isArabic
      ? 'الرجاء إدخال المبلغ واختيار الفئة'
      : 'Please enter amount and select category';
  String get enterValidAmount =>
      isArabic ? 'الرجاء إدخال مبلغ صحيح' : 'Please enter a valid amount';
  String get expenseAdded =>
      isArabic ? 'تمت إضافة المصروف!' : '💰 Expense added successfully!';
  String get failedToSaveExpense =>
      isArabic ? 'فشل حفظ المصروف' : 'Failed to save expense.';
  String get addExpense => isArabic ? 'إضافة مصروف' : 'Add Expense';

  // Debt
  String get debtRecords => isArabic ? 'سجلات الديون' : 'Debt Records';
  String get totalDebt => isArabic ? 'إجمالي الديون' : 'Total Debt';
  String get totalPayback => isArabic ? 'إجمالي المستردات' : 'Total Payback';
  String get owesYou => isArabic ? 'يدين لك' : 'Owes you';
  String get youOwe => isArabic ? 'أنت تدين' : 'You owe';
  String get addPerson => isArabic ? 'إضافة شخص' : 'Add Person';
  String get addRecord => isArabic ? 'إضافة سجل' : 'Add Record';
  String get noPeopleAddedYet =>
      isArabic ? 'لم يتم إضافة أشخاص بعد' : 'No people added yet';
  String get markAsPaid => isArabic ? 'تحديد كمدفوع؟' : 'Mark as Paid?';
  String confirmMarkAsPaid(double amount) => isArabic
      ? 'هل تريد تحديد هذا الدين بقيمة $amount كمدفوع؟'
      : 'Do you want to mark this $amount debt as paid back?';
  String get markPaid => isArabic ? 'تحديد كمدفوع' : 'Mark Paid';
  String paybackFor(String note) =>
      isArabic ? 'سداد لـ: $note' : 'Payback for: $note';
  String get markedAsPaid =>
      isArabic ? 'تم التحديد كمدفوع!' : 'Marked as paid! 💰';
  String get noRecordsYet => isArabic ? 'لا توجد سجلات بعد' : 'No records yet';
  String get debtTapToPay =>
      isArabic ? 'دين (اضغط للدفع)' : 'Debt (Tap to Pay)';
  String get payback => isArabic ? 'سداد' : 'Payback';

  // Expenses List
  String get yourExpenses => isArabic ? 'مصروفاتك' : 'Your Expenses';
  String get filter => isArabic ? 'تصفية' : 'Filter';
  String get filterExpenses => isArabic ? 'تصفية المصروفات' : 'Filter Expenses';
  String get noExpensesYet =>
      isArabic ? 'لا توجد مصروفات بعد' : 'No expenses yet';
  String get tapToAddFirstExpense => isArabic
      ? 'اضغط على + لإضافة أول مصروف'
      : 'Tap the + button to add your first expense';
  String get deleteExpense => isArabic ? 'حذف المصروف' : 'Delete Expense';
  String get confirmDeleteExpense => isArabic
      ? 'هل أنت متأكد أنك تريد حذف هذا المصروف؟'
      : 'Are you sure you want to delete this expense?';
  String get expenseDeleted =>
      isArabic ? 'تم حذف المصروف بنجاح!' : 'Expense deleted successfully! 🗑️';
  String get failedToDeleteExpense =>
      isArabic ? 'فشل حذف المصروف.' : 'Failed to delete expense.';

  // Income Management
  String get incomeManagement => isArabic ? 'إدارة الدخل' : 'Income Management';
  String get currentTotalIncome =>
      isArabic ? 'إجمالي الدخل الحالي' : 'Current Total Income';
  String get setMonthlySalary =>
      isArabic ? 'تعيين الراتب الشهري' : 'Set Monthly Salary';
  String get monthlySalaryAmount =>
      isArabic ? 'مبلغ الراتب الشهري' : 'Monthly Salary Amount';
  String get addOtherIncome => isArabic ? 'إضافة دخل آخر' : 'Add Other Income';
  String get incomeTitle => isArabic ? 'عنوان الدخل' : 'Income Title';
  String get incomeType => isArabic ? 'نوع الدخل' : 'Income Type';
  String get addIncome => isArabic ? 'إضافة دخل' : 'Add Income';
  String get enterAmountTitle => isArabic
      ? 'الرجاء إدخال المبلغ والعنوان'
      : 'Please enter amount and title';
  String get incomeAdded => isArabic ? 'تمت إضافة الدخل' : '💰 Income added';
  String get failedToAddIncome =>
      isArabic ? 'فشل إضافة الدخل.' : 'Failed to add income.';
  String get enterSalaryAmount =>
      isArabic ? 'الرجاء إدخال مبلغ الراتب' : 'Please enter salary amount';
  String get enterValidSalary => isArabic
      ? 'الرجاء إدخال راتب صحيح'
      : 'Please enter a valid salary amount';
  String get monthlySalarySet =>
      isArabic ? 'تم تعيين الراتب الشهري' : '💼 Monthly salary set';
  String get failedToSetSalary =>
      isArabic ? 'فشل تعيين الراتب.' : 'Failed to set salary.';

  // Exit confirmation
  String get exitApp => isArabic ? 'خروج من التطبيق' : 'Exit App';
  String get exitConfirmation => isArabic
      ? 'هل أنت متأكد من أنك تريد الخروج من التطبيق؟'
      : 'Are you sure you want to exit the app?';
  String get exit => isArabic ? 'خروج' : 'Exit';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
