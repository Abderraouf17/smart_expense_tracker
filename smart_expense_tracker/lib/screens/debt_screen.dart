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
import '../l10n/app_localizations.dart'; // Import localization
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/pdf_service.dart';

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

  void _showPersonMenu(person) {
    final balance = context.read<DebtProvider>().getPersonBalance(person.key.toString());
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : Colors.white,
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
              title: const Text('Edit Person'),
              onTap: () {
                Navigator.pop(context);
                _showEditPersonDialog(person);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: const Text('Delete Person'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePerson(person, balance);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPersonDialog(person) {
    final nameController = TextEditingController(text: person.name);
    final phoneController = TextEditingController(text: person.phoneNumber);
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: const Text('Edit Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                person.name = nameController.text.trim();
                person.phoneNumber = phoneController.text.trim();
                await context.read<DebtProvider>().updatePerson(person);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Person updated successfully'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF69B39C)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePerson(person, double balance) {
    final hasOutstanding = balance != 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: hasOutstanding
            ? Text(
                'This person has an outstanding balance of ${balance.abs().toStringAsFixed(2)}. '
                '${balance > 0 ? "They still owe you" : "You still owe them"}. '
                'Deleting will remove all debt records. Are you sure?',
              )
            : Text('Are you sure you want to delete ${person.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<DebtProvider>().deletePerson(person);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Person deleted'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor, // Use theme color
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = const Color(0xFF1E2E4F);

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_add, color: isDark ? Colors.tealAccent : primaryColor),
                title: Text(l10n.addPerson, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    TransparentRoute(builder: (_) => const AddPersonScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.receipt_long, color: isDark ? Colors.blueAccent : primaryColor),
                title: Text(l10n.addRecord, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    TransparentRoute(builder: (_) => const AddDebtRecordScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportPdf() async {
    final debtProvider = context.read<DebtProvider>();
    final people = debtProvider.people;
    if (people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No debt records to export.')),
      );
      return;
    }

    try {
      // Get User Name
      String userName = 'User';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
           userName = doc.data()?['name'] ?? user.email ?? 'User';
        }
      }
      
      final currencySymbol = context.read<ThemeProvider>().getCurrencySymbol();
      
      await PdfService.generateDebtsSummaryReport(
        people,
        debtProvider,
        currencySymbol,
        userName,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DebtProvider, ThemeProvider>(
      builder: (context, debtProvider, themeProvider, child) {
        final currencySymbol = themeProvider.getCurrencySymbol();
        final l10n = AppLocalizations.of(context)!;
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.debtRecords),
            backgroundColor: const Color(0xFF1E2E4F), // Navy
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: _exportPdf,
                tooltip: 'Export PDF',
              ),
            ],
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
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(l10n.totalDebt, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
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
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(l10n.totalPayback, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(l10n.noPeopleAddedYet, style: TextStyle(fontSize: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: debtProvider.people.length,
                        itemBuilder: (context, index) {
                          final person = debtProvider.people[index];
                          final balance = debtProvider.getPersonBalance(person.key.toString());
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            
                            return Container(
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF69B39C).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    person.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFF69B39C),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  person.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                                ),
                                subtitle: Text(
                                  person.phoneNumber,
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$currencySymbol${balance.abs().toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: balance > 0 ? Colors.red.shade400 : const Color(0xFF69B39C),
                                          ),
                                        ),
                                        Text(
                                          balance > 0 ? l10n.owesYou : l10n.youOwe,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_vert, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                      onPressed: () => _showPersonMenu(person),
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
                  MaterialPageRoute(builder: (_) => AnalyticsScreen()),
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