import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'models/expense.dart';
import 'models/person.dart';
import 'models/debt_record.dart';
import 'models/income_source.dart';
import 'providers/expense_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/auth_gate.dart';
import 'screens/splash_screen.dart';

// Entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(DebtRecordAdapter());
  Hive.registerAdapter(IncomeSourceAdapter());
  
  // Open Hive boxes with error handling
  try {
    await Hive.openBox<Expense>('expenses');
  } catch (e) {
    await Hive.deleteBoxFromDisk('expenses');
    await Hive.openBox<Expense>('expenses');
  }
  
  try {
    await Hive.openBox<Person>('people');
  } catch (e) {
    await Hive.deleteBoxFromDisk('people');
    await Hive.openBox<Person>('people');
  }
  
  try {
    await Hive.openBox<DebtRecord>('debt_records');
  } catch (e) {
    await Hive.deleteBoxFromDisk('debt_records');
    await Hive.openBox<DebtRecord>('debt_records');
  }
  
  try {
    await Hive.openBox('settings');
  } catch (e) {
    await Hive.deleteBoxFromDisk('settings');
    await Hive.openBox('settings');
  }
  
  try {
    await Hive.openBox<IncomeSource>('income_sources');
  } catch (e) {
    await Hive.deleteBoxFromDisk('income_sources');
    await Hive.openBox<IncomeSource>('income_sources');
  }
  
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Trackit',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(themeProvider.language),
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E2E4F),
                primary: const Color(0xFF1E2E4F),
                secondary: const Color(0xFF69B39C),
              ),
              scaffoldBackgroundColor: Colors.grey.shade50,
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E2E4F),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              textTheme: GoogleFonts.poppinsTextTheme().apply(
                bodyColor: const Color(0xFF1E2E4F),
                displayColor: const Color(0xFF1E2E4F),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E2E4F),
                brightness: Brightness.dark,
                primary: const Color(0xFF69B39C), // Use accent as primary in dark mode for visibility
                surface: const Color(0xFF1E2E4F),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              textTheme: GoogleFonts.poppinsTextTheme().apply(
                bodyColor: Colors.grey.shade200,
                displayColor: Colors.white,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                selectedItemColor: Color(0xFF69B39C),
                unselectedItemColor: Colors.grey,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

