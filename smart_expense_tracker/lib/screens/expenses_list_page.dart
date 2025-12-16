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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/pdf_service.dart';

class ExpensesListPage extends StatefulWidget {
  const ExpensesListPage({super.key});
  @override
  State<ExpensesListPage> createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends State<ExpensesListPage> {
  List<String> _selectedCategories = []; // State for selected categories in filter
  String _sortBy = 'date'; // Default sort: 'date', 'amountHigh', 'amountLow'
  
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
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.filterExpenses,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E2E4F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sort By Section
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Date (Newest First)'),
                          value: 'date',
                          groupValue: _sortBy,
                          onChanged: (value) {
                            setStateModal(() => _sortBy = value!);
                          },
                          activeColor: const Color(0xFF69B39C),
                        ),
                        RadioListTile<String>(
                          title: const Text('Amount (High to Low)'),
                          value: 'amountHigh',
                          groupValue: _sortBy,
                          onChanged: (value) {
                            setStateModal(() => _sortBy = value!);
                          },
                          activeColor: const Color(0xFF69B39C),
                        ),
                        RadioListTile<String>(
                          title: const Text('Amount (Low to High)'),
                          value: 'amountLow',
                          groupValue: _sortBy,
                          onChanged: (value) {
                            setStateModal(() => _sortBy = value!);
                          },
                          activeColor: const Color(0xFF69B39C),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Filter by Category Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      if (_selectedCategories.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setStateModal(() => _selectedCategories.clear());
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Color(0xFF69B39C)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: CategoryConstants.icons.keys.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          final color = CategoryConstants.getColor(category);
                          return FilterChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.black87),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setStateModal(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                            checkmarkColor: Colors.white,
                            backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                            selectedColor: color,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setStateModal(() {
                            _sortBy = 'date';
                            _selectedCategories.clear();
                          });
                        },
                        child: Text(
                          'Reset All',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Update parent widget state
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF69B39C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(l10n.apply),
                      ),
                    ],
                  ),
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
    final icon = CategoryConstants.getIcon(expense.category);
    final color = CategoryConstants.getColor(expense.category);
    
    final dateStr = '${expense.date.day}/${expense.date.month}/${expense.date.year}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF1E2E4F);

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF69B39C)),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      TransparentRoute(
                        builder: (_) => AddExpensePage(expense: expense),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red.shade400),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteExpense(expense);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
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

  Future<void> _exportPdf() async {
    final expenses = context.read<ExpenseProvider>().expenses;
    if (expenses.isEmpty) {
      _showErrorSnackBar('No expenses to export.');
      return;
    }

    try {
      // Get User Name
      String userName = 'User';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
           userName = doc.data()?['name'] ?? user.email ?? 'User';
        }
      }
      
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      
      await PdfService.generateExpensesReport(
        expenses,
        currencySymbol,
        userName,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to generate PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final allExpenses = expenseProvider.expenses;
        var filteredExpenses = _selectedCategories.isEmpty
            ? allExpenses
            : allExpenses.where((expense) => _selectedCategories.contains(expense.category)).toList();
        
        // Sort expenses based on selected sort option
        switch (_sortBy) {
          case 'amountHigh':
            filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
            break;
          case 'amountLow':
            filteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
            break;
          case 'date':
          default:
            filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
            break;
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.yourExpenses), // Localized
            backgroundColor: const Color(0xFF1E2E4F), // Navy
            actions: [

              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: _exportPdf,
                tooltip: 'Export PDF',
              ),
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