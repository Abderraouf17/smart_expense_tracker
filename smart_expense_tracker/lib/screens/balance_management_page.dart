import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class BalanceManagementPage extends StatefulWidget {
  const BalanceManagementPage({super.key});

  @override
  State<BalanceManagementPage> createState() => _BalanceManagementPageState();
}

class _BalanceManagementPageState extends State<BalanceManagementPage> {
  final _limitController = TextEditingController();
  bool _isEditingLimit = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLimit();
  }

  void _loadCurrentLimit() {
    final provider = context.read<ExpenseProvider>();
    final limit = provider.balanceLimit;
    if (limit != null) {
      _limitController.text = limit.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _saveLimit() {
    final limitText = _limitController.text.trim();
    final provider = context.read<ExpenseProvider>();
    
    if (limitText.isEmpty) {
      provider.setBalanceLimit(null);
      _showSuccessSnackBar('Balance limit removed');
      setState(() => _isEditingLimit = false);
      return;
    }
    
    final limit = double.tryParse(limitText);
    if (limit == null || limit < 0) {
      _showErrorSnackBar('Please enter a valid limit');
      return;
    }
    
    provider.setBalanceLimit(limit);
    _showSuccessSnackBar('Balance limit set successfully');
    setState(() => _isEditingLimit = false);
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
            Text(message),
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
        final balance = expenseProvider.balance;
        final limit = expenseProvider.balanceLimit;
        final limitReached = expenseProvider.checkBalanceLimitReached();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Balance Management', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1E2E4F),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: balance < 0
                          ? [Colors.red.shade500, Colors.red.shade700]
                          : [const Color(0xFF69B39C), const Color(0xFF69B39C).withGreen(150)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: balance < 0
                            ? Colors.red.shade400.withOpacity(0.4)
                            : const Color(0xFF69B39C).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        balance.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencySymbol,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (limit != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Limit: $currencySymbol${limit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (limitReached && limit != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, color: Colors.yellow.shade300, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Balance Limit Reached!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Set Balance Limit Section
                Text(
                  'Set Balance Limit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get notified when your balance reaches this limit',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  readOnly: !_isEditingLimit,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Balance Limit',
                    prefixIcon: Icon(Icons.notifications_active, color: isDark ? Colors.white70 : Colors.grey.shade600),
                    suffixIcon: limit != null && !_isEditingLimit
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.red.shade400),
                            onPressed: () {
                              expenseProvider.setBalanceLimit(null);
                              _limitController.clear();
                              _showSuccessSnackBar('Balance limit removed');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!_isEditingLimit)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditingLimit = true),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Edit', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    if (_isEditingLimit) ...[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditingLimit = false;
                            _loadCurrentLimit();
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
                        onPressed: _saveLimit,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Save', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF69B39C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Balance Information
                Text(
                  'Balance Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Total Income',
                        '$currencySymbol${expenseProvider.totalIncome.toStringAsFixed(2)}',
                        Icons.trending_up,
                        Colors.green,
                        isDark,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Total Expenses',
                        '$currencySymbol${expenseProvider.totalSpent.toStringAsFixed(2)}',
                        Icons.trending_down,
                        Colors.red,
                        isDark,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Current Balance',
                        '$currencySymbol${balance.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        balance < 0 ? Colors.red : const Color(0xFF69B39C),
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
