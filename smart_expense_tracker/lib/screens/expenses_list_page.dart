import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../models/expense.dart';
import 'add_expense_page.dart';
import 'debt_screen.dart';
import 'profile_screen.dart';
import 'home_dashboard.dart';

class ExpensesListPage extends StatefulWidget {
  const ExpensesListPage({super.key});
  @override
  State<ExpensesListPage> createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends State<ExpensesListPage> {
  final Map<String, IconData> categoryIcons = const {
    'Food': Icons.fastfood,
    'Travel': Icons.directions_car,
    'Bills': Icons.receipt,
    'Shopping': Icons.shopping_cart,
    'Entertainment': Icons.movie,
  };

  final Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Travel': Colors.blue,
    'Bills': Colors.yellow.shade700,
    'Shopping': Colors.purple,
    'Entertainment': Colors.redAccent,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Expenses',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 15,
                children: const [
                  FilterChip(
                    label: Text('Food'),
                    selected: true,
                    onSelected: null,
                    backgroundColor: Color(0xFFFFE0B2),
                    selectedColor: Color(0xFFFFCC80),
                  ),
                  FilterChip(
                    label: Text('Travel'),
                    selected: true,
                    onSelected: null,
                    backgroundColor: Color(0xFFBBDEFB),
                    selectedColor: Color(0xFF90CAF9),
                  ),
                  FilterChip(
                    label: Text('Bills'),
                    selected: true,
                    onSelected: null,
                    backgroundColor: Color(0xFFFFF59D),
                    selectedColor: Color(0xFFFFF176),
                  ),
                  FilterChip(
                    label: Text('Shopping'),
                    selected: true,
                    onSelected: null,
                    backgroundColor: Color(0xFFE1BEE7),
                    selectedColor: Color(0xFFCE93D8),
                  ),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Apply'),
                ),
              )
            ],
          ),
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
    final icon = categoryIcons[expense.category] ?? Icons.category;
    final color = categoryColors[expense.category] ?? Colors.grey;
    final dateStr = '${expense.date.day}/${expense.date.month}/${expense.date.year}';
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _tappedId = expense.key.toString()),
      onTapUp: (_) => setState(() => _tappedId = null),
      onTapCancel: () => setState(() => _tappedId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _tappedId == expense.key.toString() ? Colors.teal.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.3),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.note,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  _buildCategoryTag(expense.category, color),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Text('${themeProvider.getCurrencySymbol()}${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16));
                  },
                ),
                const SizedBox(height: 4),
                Text(dateStr,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteExpense(expense),
            ),
          ],
        ),
      ),
    );
  }
  
  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ExpenseProvider>().deleteExpense(expense);
                _showSuccessSnackBar('Expense deleted successfully! 🗑️');
              } catch (e) {
                _showErrorSnackBar('Failed to delete expense. Please try again.');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final expenses = expenseProvider.expenses;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Expenses'),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterModal,
                tooltip: 'Filter',
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: expenses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first expense',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return _buildExpenseItem(expenses[index]);
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics coming soon!')),
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
              MaterialPageRoute(builder: (_) => const AddExpensePage()),
            ),
          ),
        );
      },
    );
  }
}
