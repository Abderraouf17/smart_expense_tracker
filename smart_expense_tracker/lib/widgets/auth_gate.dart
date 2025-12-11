import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/debt_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, set up providers for this user
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final uid = snapshot.data!.uid;
            context.read<ExpenseProvider>().setCurrentUser(uid);
            context.read<DebtProvider>().setCurrentUser(uid);
          });
          return const HomeDashboard();
        } else {
          // User is not logged in, show login screen
          return const LoginScreen();
        }
      },
    );
  }
}