import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../models/debt_record.dart';
import '../models/person.dart';
import '../widgets/common_widgets.dart';
import 'add_person_screen.dart';

class AddDebtRecordScreen extends StatefulWidget {
  final Person? selectedPerson;
  
  const AddDebtRecordScreen({super.key, this.selectedPerson});

  @override
  State<AddDebtRecordScreen> createState() => _AddDebtRecordScreenState();
}

class _AddDebtRecordScreenState extends State<AddDebtRecordScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Person? _selectedPerson;
  String _recordType = 'debt';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedPerson = widget.selectedPerson;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _saveRecord() async {
    final amount = double.tryParse(_amountController.text.trim());
    final note = _noteController.text.trim();

    if (_selectedPerson == null) {
      _showErrorSnackBar('Please select a person');
      return;
    }

    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    final record = DebtRecord(
      amount: amount,
      type: _recordType,
      date: _selectedDate,
      note: note,
      personId: _selectedPerson!.key.toString(),
    );

    try {
      await context.read<DebtProvider>().addDebtRecord(record);
      if (!mounted) return;
      final emoji = _recordType == 'debt' ? '💸' : '💰';
      _showSuccessSnackBar('${_recordType == 'debt' ? 'Debt' : 'Payback'} record added! $emoji');
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to add record. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: GestureDetector(
              onTap: () {}, // Prevent dismissal
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2E4F), Color(0xFF69B39C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
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
                          const Text(
                            'Add Debt Record',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Person Selection
                      Consumer<DebtProvider>(
                        builder: (context, debtProvider, child) {
                          final hasPeople = debtProvider.people.isNotEmpty;
                          return Column(
                            children: [
                              if (!hasPeople)
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      TransparentRoute(builder: (_) => const AddPersonScreen()),
                                    );
                                    // Reload and auto-select the newly added person
                                    if (mounted) {
                                      await debtProvider.loadData();
                                      if (debtProvider.people.isNotEmpty) {
                                        setState(() => _selectedPerson = debtProvider.people.last);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: const Color(0xFF69B39C), width: 2),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.person_add, color: Color(0xFF69B39C)),
                                        SizedBox(width: 16),
                                        Text(
                                          'Add New Person',
                                          style: TextStyle(fontSize: 16, color: Color(0xFF69B39C), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (hasPeople)
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<Person>(
                                        decoration: InputDecoration(
                                          labelText: 'Select Person',
                                          labelStyle: const TextStyle(color: Colors.white70),
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
                                          prefixIcon: const Icon(Icons.person, color: Colors.white70),
                                        ),
                                        dropdownColor: const Color(0xFF2A2A3A),
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        value: _selectedPerson,
                                        items: debtProvider.people.map((person) => DropdownMenuItem<Person>(
                                              value: person,
                                              child: Text(person.name),
                                            )).toList(),
                                        onChanged: (person) {
                                          setState(() => _selectedPerson = person);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: const Color(0xFF69B39C), width: 2),
                                      ),
                                      child: IconButton(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            TransparentRoute(builder: (_) => const AddPersonScreen()),
                                          );
                                          // Reload and auto-select the newly added person
                                          if (mounted) {
                                            await debtProvider.loadData();
                                            if (debtProvider.people.isNotEmpty) {
                                              setState(() => _selectedPerson = debtProvider.people.last);
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.person_add, color: Color(0xFF69B39C)),
                                        iconSize: 26,
                                        tooltip: 'Add New Person',
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Amount',
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
                      // Record Type Selection
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _recordType = 'debt'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _recordType == 'debt' ? Colors.red.shade400 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Debt',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _recordType = 'payback'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _recordType == 'payback' ? Colors.green.shade400 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Payback',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date Selection
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white70),
                              const SizedBox(width: 16),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Note (optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.note, color: Colors.white70),
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
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              text: 'Cancel',
                              gradient: LinearGradient(
                                colors: [Colors.grey.shade400, Colors.grey.shade600],
                              ),
                              onPressed: () => Navigator.pop(context),
                              borderRadius: 25,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: GradientButton(
                                text: 'Save',
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                                ),
                              onPressed: _saveRecord,
                              borderRadius: 25,
                            ),
                          ),
                        ],
                      ),
                    ],
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