import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  late AnimationController _modalController;
  late Animation<double> _scaleAnimation;

  final Map<String, IconData> categoryIcons = const {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Bills & Utilities': Icons.receipt_long,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Healthcare': Icons.local_hospital,
    'Education': Icons.school,
    'Groceries': Icons.local_grocery_store,
    'Fuel & Gas': Icons.local_gas_station,
    'Coffee & Drinks': Icons.local_cafe,
    'Fitness & Gym': Icons.fitness_center,
    'Beauty & Personal Care': Icons.face_retouching_natural,
    'Travel': Icons.flight,
    'Home & Garden': Icons.home,
    'Technology': Icons.devices,
    'Clothing': Icons.checkroom,
    'Gifts & Donations': Icons.card_giftcard,
    'Insurance': Icons.security,
    'Subscriptions': Icons.subscriptions,
    'Other': Icons.more_horiz,
  };

  final Map<String, Color> categoryColors = {
    'Food & Dining': Colors.orange,
    'Transportation': Colors.blue,
    'Bills & Utilities': Colors.amber.shade700,
    'Shopping': Colors.purple,
    'Entertainment': Colors.pink,
    'Healthcare': Colors.red,
    'Education': Colors.indigo,
    'Groceries': Colors.green,
    'Fuel & Gas': Colors.grey.shade700,
    'Coffee & Drinks': Colors.brown,
    'Fitness & Gym': Colors.teal,
    'Beauty & Personal Care': Colors.pinkAccent,
    'Travel': Colors.cyan,
    'Home & Garden': Colors.lightGreen,
    'Technology': Colors.deepPurple,
    'Clothing': Colors.deepOrange,
    'Gifts & Donations': Colors.lime,
    'Insurance': Colors.blueGrey,
    'Subscriptions': Colors.indigo.shade300,
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _modalController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation =
        CurvedAnimation(parent: _modalController, curve: Curves.easeOutBack);
    _modalController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _modalController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    final amountText = _amountController.text.trim();
    final notes = _notesController.text.trim();
    
    if (amountText.isEmpty || _selectedCategory == null) {
      _showErrorSnackBar('Please enter amount and select category');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }
    
    setState(() => _isLoading = true);
    
    final expense = Expense(
      amount: amount,
      category: _selectedCategory!,
      note: notes.isEmpty ? _selectedCategory! : notes,
      date: DateTime.now(),
      currency: 'USD',
    );
    
    try {
      await context.read<ExpenseProvider>().addExpense(expense);
      if (!mounted) return;
      _showSuccessSnackBar('💰 Expense added successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Failed to save expense. Please try again.');
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

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Category *',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            prefixIcon: Icon(
              _selectedCategory != null
                  ? categoryIcons[_selectedCategory!] ?? Icons.category
                  : Icons.category_outlined,
              color: _selectedCategory != null
                  ? categoryColors[_selectedCategory!] ?? Colors.grey
                  : Colors.grey,
            ),
          ),
          value: _selectedCategory,
          items: categoryIcons.keys
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
            });
          },
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              final commonCategories = [
                'Food & Dining',
                'Coffee & Drinks', 
                'Transportation',
                'Groceries',
                'Shopping',
                'Bills & Utilities',
                'Entertainment',
                'Healthcare',
                'Fuel & Gas',
                'Other'
              ];
              final categoryName = commonCategories[index];
              final entry = MapEntry(categoryName, categoryIcons[categoryName]!);
              final isSelected = _selectedCategory == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = entry.key;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? categoryColors[entry.key]?.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: categoryColors[entry.key]!, width: 2)
                        : null,
                  ),
                  child: Icon(
                    entry.value,
                    color: categoryColors[entry.key],
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade200, Colors.blue.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Expense',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Amount *',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: _isLoading ? 'Saving...' : 'Save',
                    gradient: LinearGradient(
                      colors: _isLoading 
                          ? [Colors.grey.shade400, Colors.grey.shade600]
                          : [Colors.green.shade400, Colors.teal.shade600],
                    ),
                    onPressed: _isLoading ? () {} : _saveExpense,
                    borderRadius: 25,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
