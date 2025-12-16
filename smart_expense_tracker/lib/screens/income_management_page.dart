import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common_widgets.dart';
import '../models/income_source.dart';

class IncomeManagementPage extends StatefulWidget {
  const IncomeManagementPage({super.key});

  @override
  State<IncomeManagementPage> createState() => _IncomeManagementPageState();
}

class _IncomeManagementPageState extends State<IncomeManagementPage> {
  final _monthlySalaryController = TextEditingController();
  final _otherIncomeAmountController = TextEditingController();
  final _otherIncomeTitleController = TextEditingController();

  String _incomeType = 'Freelance';
  bool _isLoading = false;
  bool _isEditingSalary = false;
  IncomeSource? _editingSource;

  final List<String> _incomeTypes = [
    'Freelance',
    'Business',
    'Investment',
    'Rental',
    'Bonus',
    'Gift',
    'Other',
  ];

  final Map<String, IconData> _incomeIcons = {
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
    _monthlySalaryController.text = provider.monthlySalary.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _monthlySalaryController.dispose();
    _otherIncomeAmountController.dispose();
    _otherIncomeTitleController.dispose();
    super.dispose();
  }

  void _showAddEditIncomeDialog({IncomeSource? source}) {
    final isEditing = source != null;
    _editingSource = source;
    
    if (isEditing) {
      _otherIncomeTitleController.text = source.title;
      _otherIncomeAmountController.text = source.amount.toStringAsFixed(2);
      _incomeType = source.type;
    } else {
      _otherIncomeTitleController.clear();
      _otherIncomeAmountController.clear();
      _incomeType = 'Freelance';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return AlertDialog(
            title: Text(isEditing ? 'Edit Income Source' : 'Add Income Source'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _otherIncomeTitleController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title, color: isDark ? Colors.white70 : Colors.grey.shade600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otherIncomeAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Amount',
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
                      labelText: 'Type',
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
                      setStateDialog(() => _incomeType = value!);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    _updateIncomeSource();
                  } else {
                    _addIncomeSource();
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF69B39C),
                ),
                child: Text(isEditing ? 'Update' : 'Add', style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addIncomeSource() async {
    final title = _otherIncomeTitleController.text.trim();
    final amountText = _otherIncomeAmountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      _showErrorSnackBar('Please enter all fields');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    final source = IncomeSource(
      title: title,
      amount: amount,
      type: _incomeType,
      date: DateTime.now(),
    );

    try {
      await context.read<ExpenseProvider>().addIncomeSource(source);
      if (!mounted) return;
      _showSuccessSnackBar('Income source added successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to add income source');
    }
  }

  void _updateIncomeSource() async {
    if (_editingSource == null) return;
    
    final title = _otherIncomeTitleController.text.trim();
    final amountText = _otherIncomeAmountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      _showErrorSnackBar('Please enter all fields');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    _editingSource!.title = title;
    _editingSource!.amount = amount;
    _editingSource!.type = _incomeType;

    try {
      await context.read<ExpenseProvider>().updateIncomeSource(_editingSource!);
      if (!mounted) return;
      _showSuccessSnackBar('Income source updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update income source');
    }
  }

  void _deleteIncomeSource(IncomeSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income Source'),
        content: Text('Are you sure you want to delete "${source.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ExpenseProvider>().deleteIncomeSource(source);
                _showSuccessSnackBar('Income source deleted');
              } catch (e) {
                _showErrorSnackBar('Failed to delete income source');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateMonthlySalary() async {
    final amountText = _monthlySalaryController.text.trim();

    if (amountText.isEmpty) {
      _showErrorSnackBar('Please enter salary amount');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      _showErrorSnackBar('Please enter a valid salary');
      return;
    }

    setState(() => _isLoading = true);

    try {
      context.read<ExpenseProvider>().setMonthlySalary(amount);
      
      if (!mounted) return;
      _showSuccessSnackBar('Monthly salary updated');
      
      setState(() => _isEditingSalary = false);
      
    } catch (e) {
      _showErrorSnackBar('Failed to update salary');
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
        final totalIncome = expenseProvider.totalIncome;
        final monthlySalary = expenseProvider.monthlySalary;
        final otherIncome = expenseProvider.otherIncomesTotal;
        final incomeSources = expenseProvider.incomeSources;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Income Management', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1E2E4F),
            iconTheme: const IconThemeData(color: Colors.white),
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
                      colors: [Color(0xFF1E2E4F), Color(0xFF69B39C)],
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
                          const Text('Total Income', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currencySymbol${totalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildIncomeChip('Salary: $currencySymbol${monthlySalary.toStringAsFixed(2)}', Icons.work),
                          const SizedBox(width: 8),
                          _buildIncomeChip('Other: $currencySymbol${otherIncome.toStringAsFixed(2)}', Icons.add_circle),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Set Monthly Salary Section
                Text(
                  'Monthly Salary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _monthlySalaryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  readOnly: !_isEditingSalary,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Monthly Salary Amount',
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
                        label: const Text('Edit', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    if (_isEditingSalary) ...[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditingSalary = false;
                            _loadCurrentMonthlySalary();
                          });
                        },
                        child: const Text('Cancel'),
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
                        label: Text(_isLoading ? 'Saving...' : 'Save', style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2E4F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 30),

                // Other Income Sources Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Other Income Sources',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showAddEditIncomeDialog(),
                      icon: const Icon(Icons.add_circle, color: Color(0xFF69B39C)),
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (incomeSources.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.attach_money, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No other income sources yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: incomeSources.length,
                    itemBuilder: (context, index) {
                      final source = incomeSources[index];
                      final icon = _incomeIcons[source.type] ?? Icons.attach_money;
                      
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
                                      _showAddEditIncomeDialog(source: source);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red.shade400),
                                    title: const Text('Delete'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _deleteIncomeSource(source);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF69B39C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: const Color(0xFF69B39C), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      source.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      source.type,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$currencySymbol${source.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : const Color(0xFF1E2E4F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}