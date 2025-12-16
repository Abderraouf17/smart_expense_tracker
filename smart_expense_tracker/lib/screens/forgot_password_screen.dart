import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (email.isEmpty) {
      _showSnackBar(l10n.enterEmailPassword, Colors.orange); // Reusing 'Enter Email' msg part essentially
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSnackBar('Password reset link sent! Check your email.', Colors.green);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send reset email.';
      if (e.code == 'user-not-found') msg = 'No user found with this email.';
      if (e.code == 'invalid-email') msg = 'Invalid email address.';
      _showSnackBar(msg, Colors.red);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!; // Utilizing l10n wherever possible

    // Theme Gradients
    final gradientColors = isDark
        ? [const Color(0xFF121212), const Color(0xFF1E2E4F)]
        : [
            const Color(0xFF1E2E4F), // Navy
            const Color(0xFF456B9C), // Lighter Navy
            const Color(0xFF69B39C) // Teal
          ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(color: isDark ? const Color(0xFF121212) : Colors.white),
          AbstractBackground(colors: gradientColors),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Text
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your email address and we will send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Input
                  AnimatedInputField(
                    labelText: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                    // Force white/light styling for this screen since it's on gradient
                  ),
                  
                  const SizedBox(height: 30),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: _isLoading ? 'Sending...' : 'Send Reset Link',
                      onPressed: _isLoading ? () {} : _resetPassword,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF69B39C),
                          Colors.teal.shade700,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
