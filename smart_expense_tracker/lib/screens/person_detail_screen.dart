import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../providers/theme_provider.dart';
import '../models/person.dart';
import '../models/debt_record.dart';
import '../widgets/common_widgets.dart';
import 'add_debt_record_screen.dart';
import '../l10n/app_localizations.dart'; // Import localization

class PersonDetailScreen extends StatefulWidget {
  final Person person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtProvider>().loadData();
    });
  }

  void _markAsPaid(DebtRecord record) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsPaid),
        content: Text(l10n.confirmMarkAsPaid(record.amount)), // Pass amount for dynamic content
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final paybackRecord = DebtRecord(
                amount: record.amount,
                type: 'payback',
                date: DateTime.now(),
                note: l10n.paybackFor(record.note), // Localize note
                personId: widget.person.key.toString(),
              );
              await context.read<DebtProvider>().addDebtRecord(paybackRecord);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.markedAsPaid),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(l10n.markPaid, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DebtProvider, ThemeProvider>(
      builder: (context, debtProvider, themeProvider, child) {
        final currencySymbol = themeProvider.getCurrencySymbol();
        final records = debtProvider.getRecordsForPerson(widget.person.key.toString());
        final balance = debtProvider.getPersonBalance(widget.person.key.toString());
        final isDark = themeProvider.isDarkMode;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.person.name, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1E2E4F), // Navy
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              // Person Info & Balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E2E4F), Color(0xFF69B39C)], // Navy to Teal
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        widget.person.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.person.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      widget.person.phoneNumber,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Column(
                        children: [
                          Text(
                            balance > 0 ? l10n.owesYou : l10n.youOwe,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          Text(
                            '$currencySymbol${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: balance > 0 ? Colors.redAccent.shade100 : Colors.greenAccent.shade100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Records List
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(l10n.noRecordsYet, style: TextStyle(fontSize: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final isDebt = record.type == 'debt';
                          
                          return GestureDetector(
                            onTap: isDebt ? () => _markAsPaid(record) : null,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isDebt ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                  child: Icon(
                                    isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: isDebt ? Colors.red : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  '$currencySymbol${record.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDebt ? l10n.debtTapToPay : l10n.payback, // Localized
                                      style: TextStyle(
                                        color: isDebt ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (record.note.isNotEmpty) Text(record.note, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                                  ],
                                ),
                                trailing: Text(
                                  '${record.date.day}/${record.date.month}/${record.date.year}',
                                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: BounceFloatingButton(
            icon: Icons.add,
            onPressed: () => Navigator.push(
              context,
              TransparentRoute(
                builder: (_) => AddDebtRecordScreen(selectedPerson: widget.person),
              ),
            ),
          ),
        );
      },
    );
  }
}