import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../providers/theme_provider.dart';
import '../models/person.dart';
import '../models/debt_record.dart';
import '../widgets/common_widgets.dart';
import 'add_debt_record_screen.dart';
import '../l10n/app_localizations.dart'; // Import localization
import '../services/pdf_service.dart';

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
    if (record.isPaid) return; // Already paid, do nothing
    
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsPaid),
        content: Text(l10n.confirmMarkAsPaid(record.amount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<DebtProvider>().markRecordAsPaid(record);
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

  Future<void> _exportPdf() async {
    try {
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      final records = context.read<DebtProvider>().getRecordsForPerson(widget.person.key.toString());
      
      await PdfService.generatePersonReport(
        widget.person,
        records,
        currencySymbol,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
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
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: _exportPdf,
                tooltip: 'Export PDF',
              ),
            ],
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
                          final isPaid = record.isPaid;
                          
                          return GestureDetector(
                            onTap: (isDebt && !isPaid) ? () => _markAsPaid(record) : null,
                            child: Opacity(
                              opacity: isPaid ? 0.5 : 1.0,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isPaid
                                        ? (isDark ? Colors.green.shade800 : Colors.green.shade200)
                                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                                    width: isPaid ? 2 : 1,
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
                                    backgroundColor: isPaid
                                        ? Colors.green.withOpacity(0.2)
                                        : (isDebt ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                                    child: Icon(
                                      isPaid
                                          ? Icons.check_circle
                                          : (isDebt ? Icons.arrow_upward : Icons.arrow_downward),
                                      color: isPaid
                                          ? Colors.green
                                          : (isDebt ? Colors.red : Colors.green),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        '$currencySymbol${record.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                          decoration: isPaid ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      if (isPaid) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'PAID',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPaid
                                            ? 'Paid'
                                            : (isDebt ? l10n.debtTapToPay : l10n.payback),
                                        style: TextStyle(
                                          color: isPaid
                                              ? Colors.green
                                              : (isDebt ? Colors.red : Colors.green),
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