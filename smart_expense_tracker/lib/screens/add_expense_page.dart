import 'dart:ui'; // Ensure this import is present
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart'; // Import localization

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
    final l10n = AppLocalizations.of(context)!;
    final amountText = _amountController.text.trim();
    final notes = _notesController.text.trim();
    
    if (amountText.isEmpty || _selectedCategory == null) {
      _showErrorSnackBar(l10n.enterAmountCategory);
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar(l10n.enterValidAmount);
      return;
    }
    
    setState(() => _isLoading = true);
    
    final expense = Expense(
      amount: amount,
      category: _selectedCategory!,
      note: notes.isEmpty ? _selectedCategory! : notes,
      date: DateTime.now(),
      currency: 'SAR', // Use default SAR
    );
    
    try {
      await context.read<ExpenseProvider>().addExpense(expense);
      if (!mounted) return;
      _showSuccessSnackBar(l10n.expenseAdded);
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('${l10n.failedToSaveExpense} $e');
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.category,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            prefixIcon: Icon(
              _selectedCategory != null
                  ? CategoryConstants.getIcon(_selectedCategory!)
                  : Icons.category_outlined,
              color: _selectedCategory != null
                  ? CategoryConstants.getColor(_selectedCategory!)
                  : Colors.grey,
            ),
          ),
          value: _selectedCategory,
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          items: CategoryConstants.icons.keys
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: CategoryConstants.icons.keys.length, // Use all categories
            itemBuilder: (context, index) {
              final categoryName = CategoryConstants.icons.keys.elementAt(index);
              final icon = CategoryConstants.getIcon(categoryName);
              final color = CategoryConstants.getColor(categoryName);
              final isSelected = _selectedCategory == categoryName;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = categoryName;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.3)
                        : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: color,
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Consistent Navy/Teal Gradient
    final gradientColors = [
      const Color(0xFF1E2E4F), // Navy
      const Color(0xFF69B39C), // Teal
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blur Background with Dismissal
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: () {}, // Prevent dismissal when tapping content
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.addExpense,
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
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
                            labelText: l10n.amount,
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
                            labelText: l10n.notes,
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
                          text: _isLoading ? '${l10n.saving}...' : l10n.save,
                          gradient: LinearGradient(
                            colors: _isLoading 
                                ? [Colors.grey.shade400, Colors.grey.shade600]
                                : [Colors.white24, Colors.white10], // Subtle difference for button on gradient
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
          ),
        ],
      ),
    );
  }
}