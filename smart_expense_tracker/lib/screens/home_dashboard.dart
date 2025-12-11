import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/common_widgets.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import 'add_expense_page.dart';
import 'expenses_list_page.dart';
import 'debt_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'income_management_page.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardsController;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _cardsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _cardsAnimation =
        CurvedAnimation(parent: _cardsController, curve: Curves.easeOutBack);
    _cardsController.forward();
    
    // Load expenses when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  void _showNavigationFeedback(int index) {
    final pages = ['Home', 'Expenses', 'Debt', 'Analytics', 'Profile'];
    if (index < pages.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${pages[index]}...'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  Widget _buildExpenseCard(String title, String amount, Color color, IconData icon) {
    return ScaleTransition(
      scale: _cardsAnimation,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildChartPlaceholder(bool isDark) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.blueGrey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.spendingTrends,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.blueGrey,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Consumer2<ExpenseProvider, ThemeProvider>(
      builder: (context, expenseProvider, themeProvider, child) {
        final currencySymbol = themeProvider.getCurrencySymbol();
        final balance = expenseProvider.balance;
        final income = expenseProvider.totalIncome;
        final expenses = expenseProvider.totalSpent;
        final monthlyExpenses = expenseProvider.totalSpentThisMonth;
        final dailyExpenses = expenseProvider.totalSpentToday;
        final recentExpenses = expenseProvider.recentExpenses;

        return Scaffold(
          appBar: AppBar(
            title: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
              builder: (context, snapshot) {
                String userName = 'User';
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  userName = data?['name'] ?? 'User';
                }
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.hello}, $userName');
              },
            ),
            backgroundColor: Colors.teal,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance and Income Cards
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const IncomeManagementPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade400, Colors.teal.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  const Text('Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  const Spacer(),
                                  const Icon(Icons.add, color: Colors.white70, size: 16),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$currencySymbol${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.purple.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trending_up, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text('Income', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$currencySymbol${income.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Expense Summary Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildExpenseCard('This Month', '$currencySymbol${monthlyExpenses.toStringAsFixed(2)}', Colors.orange, Icons.calendar_month),
                      const SizedBox(width: 12),
                      _buildExpenseCard('Today', '$currencySymbol${dailyExpenses.toStringAsFixed(2)}', Colors.red, Icons.today),
                      const SizedBox(width: 12),
                      _buildExpenseCard('Total Spent', '$currencySymbol${expenses.toStringAsFixed(2)}', Colors.deepPurple, Icons.receipt_long),
                    ],
                  ),
                ),
                _buildChartPlaceholder(themeProvider.isDarkMode),
                const SizedBox(height: 20),
                // Recent Expenses List
                Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: recentExpenses.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses yet',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: recentExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = recentExpenses[index];
                            return Card(
                              color: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade100,
                                  child: const Icon(Icons.receipt, color: Colors.teal),
                                ),
                                title: Text(
                                  expense.note,
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  expense.category,
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                trailing: Text(
                                  '$currencySymbol${expense.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: BounceFloatingButton(
            icon: Icons.add,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddExpensePage()),
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 0,
            onTap: (index) {
              _showNavigationFeedback(index);
              if (index == 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ExpensesListPage()),
                );
              }
              if (index == 2) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DebtScreen()),
                );
              }
              if (index == 3) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              }
              if (index == 4) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
          ),
        );
      },
    );
  }
}
