import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../models/expense.dart';
import '../utils/constants.dart'; // Import CategoryConstants
import 'add_expense_page.dart';
import 'debt_screen.dart';
import 'profile_screen.dart';
import 'home_dashboard.dart';
import 'analytics_screen.dart';
import '../l10n/app_localizations.dart'; // Import localization

class ExpensesListPage extends StatefulWidget {
  const ExpensesListPage({super.key});
  @override
  State<ExpensesListPage> createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends State<ExpensesListPage> {
  List<String> _selectedCategories = []; // State for selected categories in filter
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  void _showFilterModal() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor, // Use theme color
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 350, // Increased height for more categories
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.filterExpenses, // Localized
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E2E4F))), // Navy
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: CategoryConstants.icons.keys.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          final color = CategoryConstants.getColor(category);
                          return FilterChip(
                            label: Text(category, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.black87))),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setStateModal(() { // Use setStateModal for modal's state
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                            checkmarkColor: Colors.white,
                            backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                            selectedColor: color, // Use category color when selected
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Update parent widget state to apply filter
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF69B39C), // Teal
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(l10n.apply), // Localized
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryTag(String category, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String? _tappedId;

  Widget _buildExpenseItem(Expense expense) {
    // Use Constants for Icon and Color
    final icon = CategoryConstants.getIcon(expense.category);
    final color = CategoryConstants.getColor(expense.category);
    
    final dateStr = '${expense.date.day}/${expense.date.month}/${expense.date.year}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF1E2E4F); // Navy

    return GestureDetector(
      onTapDown: (_) => setState(() => _tappedId = expense.key.toString()),
      onTapUp: (_) => setState(() => _tappedId = null),
      onTapCancel: () => setState(() => _tappedId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _tappedId == expense.key.toString() 
              ? (isDark ? const Color(0xFF333333) : Colors.grey.shade100) 
              : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.note,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildCategoryTag(expense.category, color),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Text(
                      '${themeProvider.getCurrencySymbol()}${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade700, // Darker grey for light mode
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () => _deleteExpense(expense),
            ),
          ],
        ),
      ),
    );
  }
  
  void _deleteExpense(Expense expense) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExpense), // Localized
        content: Text(l10n.confirmDeleteExpense), // Localized
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ExpenseProvider>().deleteExpense(expense);
                _showSuccessSnackBar(l10n.expenseDeleted); // Localized
              } catch (e) {
                _showErrorSnackBar('${l10n.failedToDeleteExpense} $e'); // Localized
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)), // Localized
          ),
        ],
      ),
    );
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
        duration: const Duration(seconds: 2),
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final allExpenses = expenseProvider.expenses;
        final filteredExpenses = _selectedCategories.isEmpty
            ? allExpenses
            : allExpenses.where((expense) => _selectedCategories.contains(expense.category)).toList();
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.yourExpenses), // Localized
            backgroundColor: const Color(0xFF1E2E4F), // Navy
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterModal,
                tooltip: l10n.filter, // Localized
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noExpensesYet, // Localized
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tapToAddFirstExpense, // Localized
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      return _buildExpenseItem(filteredExpenses[index]);
                    },
                  ),
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeDashboard()),
                );
              }
              if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DebtScreen()),
                );
              }
              if (index == 3) {
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AnalyticsScreen()),
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
          floatingActionButton: BounceFloatingButton(
            icon: Icons.add,
            onPressed: () => Navigator.of(context).push(
              TransparentRoute(builder: (_) => const AddExpensePage()),
            ),
          ),
        );
      },
    );
  }
}