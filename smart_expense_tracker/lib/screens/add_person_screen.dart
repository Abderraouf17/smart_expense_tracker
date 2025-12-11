import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../models/person.dart';
import '../widgets/common_widgets.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _savePerson() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    final person = Person(name: name, phoneNumber: phone);

    try {
      await context.read<DebtProvider>().addPerson(person);
      if (!mounted) return;
      _showSuccessSnackBar('Person added successfully! 👤');
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to add person. Please try again.');
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
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade200, Colors.blue.shade200],
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
                const Text(
                  'Add Person',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedInputField(
                  labelText: 'Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                AnimatedInputField(
                  labelText: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone, color: Colors.white70),
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
                          colors: [Colors.green.shade400, Colors.teal.shade600],
                        ),
                        onPressed: _savePerson,
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
    );
  }
}