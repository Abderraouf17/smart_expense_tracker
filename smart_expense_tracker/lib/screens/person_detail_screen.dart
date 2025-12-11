import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../providers/theme_provider.dart';
import '../models/person.dart';
import '../widgets/common_widgets.dart';
import 'add_debt_record_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer2<DebtProvider, ThemeProvider>(
      builder: (context, debtProvider, themeProvider, child) {
        final currencySymbol = themeProvider.getCurrencySymbol();
        final records = debtProvider.getRecordsForPerson(widget.person.key.toString());
        final balance = debtProvider.getPersonBalance(widget.person.key.toString());

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.person.name),
            backgroundColor: Colors.teal,
          ),
          body: Column(
            children: [
              // Person Info & Balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade100, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal.shade200,
                      child: Text(
                        widget.person.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.person.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.person.phoneNumber,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: balance > 0 ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            balance > 0 ? 'Owes You' : 'You Owe',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$currencySymbol${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: balance > 0 ? Colors.red.shade700 : Colors.green.shade700,
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
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No records yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final isDebt = record.type == 'debt';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDebt ? Colors.red.shade100 : Colors.green.shade100,
                                child: Icon(
                                  isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: isDebt ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(
                                '$currencySymbol${record.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDebt ? Colors.red.shade700 : Colors.green.shade700,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDebt ? 'Debt' : 'Payback',
                                    style: TextStyle(
                                      color: isDebt ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (record.note.isNotEmpty) Text(record.note),
                                ],
                              ),
                              trailing: Text(
                                '${record.date.day}/${record.date.month}/${record.date.year}',
                                style: const TextStyle(color: Colors.grey),
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
              MaterialPageRoute(
                builder: (_) => AddDebtRecordScreen(selectedPerson: widget.person),
              ),
            ),
          ),
        );
      },
    );
  }
}