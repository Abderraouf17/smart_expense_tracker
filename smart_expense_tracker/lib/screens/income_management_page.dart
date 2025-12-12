import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common_widgets.dart';

class IncomeManagementPage extends StatefulWidget {
  const IncomeManagementPage({super.key});

  @override
  State<IncomeManagementPage> createState() => _IncomeManagementPageState();
}

class _IncomeManagementPageState extends State<IncomeManagementPage> {
  final _monthlySalaryController = TextEditingController(); // Specific controller for monthly salary
  final _otherIncomeAmountController = TextEditingController(); // Controller for other income amount
  final _otherIncomeTitleController = TextEditingController(); // Controller for other income title

  String _incomeType = 'Salary';
  bool _isLoading = false;
  bool _isEditingSalary = false; // State to manage salary input editability

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
  void initState() {
    super.initState();
    _loadCurrentMonthlySalary();
  }

  void _loadCurrentMonthlySalary() {
    final provider = context.read<ExpenseProvider>();
    _monthlySalaryController.text = provider.totalIncome.toStringAsFixed(2); // Display current income as salary initially
  }

  @override
  void dispose() {
    _monthlySalaryController.dispose();
    _otherIncomeAmountController.dispose();
    _otherIncomeTitleController.dispose();
    super.dispose();
  }

  void _addOtherIncome() async {
    final l10n = AppLocalizations.of(context)!;
    final amountText = _otherIncomeAmountController.text.trim();
    final title = _otherIncomeTitleController.text.trim();

    if (amountText.isEmpty || title.isEmpty) {
      _showErrorSnackBar(l10n.enterAmountTitle);
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar(l10n.enterValidAmount);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ExpenseProvider>();
      final currentIncome = provider.totalIncome;
      provider.setIncome(currentIncome + amount);
      
      if (!mounted) return;
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      _showSuccessSnackBar('${l10n.incomeAdded}: $currencySymbol${amount.toStringAsFixed(2)}');
      
      _otherIncomeAmountController.clear();
      _otherIncomeTitleController.clear();
      setState(() => _incomeType = 'Salary');
      
    } catch (e) {
      _showErrorSnackBar('${l10n.failedToAddIncome} $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateMonthlySalary() async {
    final l10n = AppLocalizations.of(context)!;
    final amountText = _monthlySalaryController.text.trim();

    if (amountText.isEmpty) {
      _showErrorSnackBar(l10n.enterSalaryAmount);
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar(l10n.enterValidSalary);
      return;
    }

    setState(() => _isLoading = true);

    try {
      context.read<ExpenseProvider>().setIncome(amount);
      
      if (!mounted) return;
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      _showSuccessSnackBar('${l10n.monthlySalarySet}: $currencySymbol${amount.toStringAsFixed(2)}');
      
      setState(() => _isEditingSalary = false); // Disable editing after saving
      
    } catch (e) {
      _showErrorSnackBar('${l10n.failedToSetSalary} $e');
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
        final l10n = AppLocalizations.of(context)!;
        final isDark = themeProvider.isDarkMode;
        final currencySymbol = themeProvider.getCurrencySymbol();
        final currentIncome = expenseProvider.totalIncome;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.incomeManagement),
            backgroundColor: const Color(0xFF1E2E4F), // Navy
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E2E4F), Color(0xFF69B39C)], // Navy to Teal
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(l10n.currentTotalIncome, style: const TextStyle(color: Colors.white70, fontSize: 16)),
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
                  l10n.setMonthlySalary,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _monthlySalaryController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  readOnly: !_isEditingSalary, // Make read-only when not editing
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87), // Ensure text color is visible
                  decoration: InputDecoration(
                    labelText: l10n.monthlySalaryAmount,
                    prefixText: currencySymbol,
                    prefixIcon: Icon(Icons.work, color: isDark ? Colors.white70 : Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!_isEditingSalary)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditingSalary = true),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: Text(l10n.update, style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    if (_isEditingSalary) ...[
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isEditingSalary = false;
                          _loadCurrentMonthlySalary(); // Revert changes
                        }),
                        child: Text(l10n.cancel),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateMonthlySalary,
                        icon: _isLoading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(_isLoading ? l10n.setting : l10n.save, style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2E4F), // Navy
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 30),

                // Add Other Income Section
                Text(
                  l10n.addOtherIncome,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otherIncomeTitleController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: l10n.incomeTitle,
                    prefixIcon: Icon(Icons.title, color: isDark ? Colors.white70 : Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField( // Amount field for other income
                  controller: _otherIncomeAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixText: currencySymbol,
                    prefixIcon: Icon(Icons.attach_money, color: isDark ? Colors.white70 : Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _incomeType,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  decoration: InputDecoration(
                    labelText: l10n.incomeType,
                    prefixIcon: Icon(_incomeIcons[_incomeType], color: isDark ? Colors.white70 : Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                  items: _incomeTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_incomeIcons[type], size: 20, color: isDark ? Colors.white70 : Colors.grey.shade600),
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
                    onPressed: _isLoading ? null : _addOtherIncome,
                    icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add, color: Colors.white),
                    label: Text(_isLoading ? l10n.adding : l10n.addIncome, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF69B39C), // Teal
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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