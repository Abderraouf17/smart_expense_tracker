import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common_widgets.dart';
import 'person_detail_screen.dart';
import 'add_person_screen.dart';
import 'add_debt_record_screen.dart';
import 'expenses_list_page.dart';
import 'profile_screen.dart';
import 'home_dashboard.dart';
import 'analytics_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtProvider>().loadData();
    });
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.teal),
              title: const Text('Add Person'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPersonScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: const Text('Add Record'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDebtRecordScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DebtProvider, ThemeProvider>(
      builder: (context, debtProvider, themeProvider, child) {
        final currencySymbol = themeProvider.getCurrencySymbol();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Debt Records'),
            backgroundColor: Colors.teal,
          ),
          body: Column(
            children: [
              // Summary Cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Total Debt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                '$currencySymbol${debtProvider.totalDebt.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 20, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Total Payback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                '$currencySymbol${debtProvider.totalPayback.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 20, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // People List
              Expanded(
                child: debtProvider.people.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No people added yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: debtProvider.people.length,
                        itemBuilder: (context, index) {
                          final person = debtProvider.people[index];
                          final balance = debtProvider.getPersonBalance(person.key.toString());
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Text(person.name[0].toUpperCase()),
                              ),
                              title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(person.phoneNumber),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$currencySymbol${balance.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: balance > 0 ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  Text(
                                    balance > 0 ? 'Owes you' : 'You owe',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PersonDetailScreen(person: person),
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
            onPressed: _showAddOptions,
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeDashboard()),
                );
              }
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpensesListPage()),
                );
              }
              if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
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
        );
      },
    );
  }
}