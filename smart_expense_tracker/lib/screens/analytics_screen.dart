import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common_widgets.dart';
import 'home_dashboard.dart';
import 'expenses_list_page.dart';
import 'debt_screen.dart';
import 'profile_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ExpenseProvider>().loadExpenses();
      
    } catch (e) {
      _showErrorSnackBar('Failed to load analytics data');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categoryTotals, String currencySymbol, bool isDark) {
    if (categoryTotals.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedCategories.take(5).map((entry) {
            final percentage = (entry.value / categoryTotals.values.reduce((a, b) => a + b)) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '$currencySymbol${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(List<Map<String, dynamic>> monthlyData, String currencySymbol, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (monthlyData.isEmpty)
            Center(
              child: Text(
                'No data available',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            )
          else
            ...monthlyData.take(6).map((data) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['month'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '$currencySymbol${data['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, ThemeProvider>(
      builder: (context, expenseProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final currencySymbol = themeProvider.getCurrencySymbol();
        final categoryTotals = expenseProvider.categoryTotals;
        
        // Calculate monthly breakdown
        final monthlyData = <Map<String, dynamic>>[];
        final now = DateTime.now();
        for (int i = 0; i < 6; i++) {
          final month = DateTime(now.year, now.month - i);
          final monthExpenses = expenseProvider.expenses
              .where((expense) => 
                  expense.date.year == month.year && 
                  expense.date.month == month.month)
              .fold(0.0, (sum, expense) => sum + expense.amount);
          
          monthlyData.add({
            'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
            'amount': monthExpenses,
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
          ),
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 16),
                      Text('Loading analytics...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'This Month',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$currencySymbol${expenseProvider.totalSpentThisMonth.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                categoryTotals.length.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Category Chart
                _buildCategoryChart(categoryTotals, currencySymbol, isDark),
                const SizedBox(height: 20),
                
                // Monthly Breakdown
                _buildMonthlyBreakdown(monthlyData, currencySymbol, isDark),
                    ],
                  ),
                ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 3,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeDashboard()),
                );
              }
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpensesListPage()),
                );
              }
              if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DebtScreen()),
                );
              }
              if (index == 4) {
                Navigator.pushReplacement(
                  context,
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