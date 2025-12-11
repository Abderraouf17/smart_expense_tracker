import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

class IncomeManagementPage extends StatefulWidget {
  const IncomeManagementPage({super.key});

  @override
  State<IncomeManagementPage> createState() => _IncomeManagementPageState();
}

class _IncomeManagementPageState extends State<IncomeManagementPage> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  String _incomeType = 'Salary';
  bool _isLoading = false;

  final List<String> _incomeTypes = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Rental',
    'Bonus',
    'Gift',
    'Other',
  ];

  final Map<String, IconData> _incomeIcons = {
    'Salary': Icons.work,
    'Freelance': Icons.laptop,
    'Business': Icons.business,
    'Investment': Icons.trending_up,
    'Rental': Icons.home,
    'Bonus': Icons.star,
    'Gift': Icons.card_giftcard,
    'Other': Icons.attach_money,
  };

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _addIncome() async {
    final amount = double.tryParse(_amountController.text.trim());
    final title = _titleController.text.trim();

    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (title.isEmpty) {
      _showErrorSnackBar('Please enter income title');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ExpenseProvider>();
      final currentIncome = provider.totalIncome;
      provider.setIncome(currentIncome + amount);
      
      if (!mounted) return;
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      _showSuccessSnackBar('💰 Income added: $currencySymbol${amount.toStringAsFixed(2)}');
      
      _amountController.clear();
      _titleController.clear();
      setState(() => _incomeType = 'Salary');
      
    } catch (e) {
      _showErrorSnackBar('Failed to add income. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setMonthlySalary() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid salary amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      context.read<ExpenseProvider>().setIncome(amount);
      
      if (!mounted) return;
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      _showSuccessSnackBar('💼 Monthly salary set: $currencySymbol${amount.toStringAsFixed(2)}');
      
      _amountController.clear();
      _titleController.clear();
      
    } catch (e) {
      _showErrorSnackBar('Failed to set salary. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, ThemeProvider>(
      builder: (context, expenseProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final currencySymbol = themeProvider.getCurrencySymbol();
        final currentIncome = expenseProvider.totalIncome;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Income Management'),
            backgroundColor: Colors.teal,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Income Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.teal.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text('Current Total Income', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currencySymbol${currentIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Set Monthly Salary Section
                Text(
                  'Set Monthly Salary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Monthly Salary Amount',
                    prefixText: currencySymbol,
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _setMonthlySalary,
                    icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Setting...' : 'Set Monthly Salary'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Add Other Income Section
                Text(
                  'Add Other Income',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Income Title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _incomeType,
                  decoration: InputDecoration(
                    labelText: 'Income Type',
                    prefixIcon: Icon(_incomeIcons[_incomeType]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                  items: _incomeTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_incomeIcons[type], size: 20),
                        const SizedBox(width: 12),
                        Text(type),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _incomeType = value!);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addIncome,
                    icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add),
                    label: Text(_isLoading ? 'Adding...' : 'Add Income'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}