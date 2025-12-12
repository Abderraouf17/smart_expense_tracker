import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));
  }

  void _onButtonTapDown(TapDownDetails _) {
    _buttonController.forward();
  }

  Future<void> _signUp() async {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('⚠️ Please fill in all fields'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Passwords do not match'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Flexible(child: Text('Account created successfully! Welcome!')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      // Navigate to dashboard after successful signup
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      });
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed';
      if (e.code == 'weak-password') msg = 'Password is too weak';
      if (e.code == 'email-already-in-use') msg = 'Email already in use';
      if (e.code == 'invalid-email') msg = 'Invalid email address';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(child: Text(msg)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onButtonTapUp(TapUpDetails _) {
    _buttonController.reverse();
    if (!_loading) {
      _signUp();
    }
  }

  void _onButtonTapCancel() {
    _buttonController.reverse();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Widget _iconForField(String field, bool isDark) {
    final color = isDark ? Colors.white70 : const Color(0xFF1E2E4F); // Navy or White
    final accentColor = isDark ? Colors.tealAccent : const Color(0xFF69B39C); // Teal

    switch (field) {
      case 'Full Name':
        return Icon(Icons.person_outline, color: color); 
      case 'Email':
        return Icon(Icons.email_outlined, color: color); 
      case 'Password':
        return Icon(Icons.lock_outline, color: color); 
      case 'Confirm Password':
        return Icon(Icons.lock_outline, color: accentColor); 
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // New Theme Gradients
    final gradientColors = isDark 
      ? [const Color(0xFF1E2E4F), const Color(0xFF121212)] 
      : [
          const Color(0xFF69B39C), // Teal
          const Color(0xFF456B9C), // Lighter Navy
          const Color(0xFF1E2E4F)  // Navy
        ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          Container(color: isDark ? const Color(0xFF121212) : Colors.white),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 1.0,
            child: AbstractBackground(colors: gradientColors),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center Align
                  children: [
                    // Top Bar (Settings)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Language Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: themeProvider.language,
                              dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                              icon: Icon(Icons.language, color: isDark ? Colors.white70 : Colors.white),
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E2E4F),
                                fontWeight: FontWeight.bold
                              ),
                              items: const [
                                DropdownMenuItem(value: 'en', child: Text('EN')),
                                DropdownMenuItem(value: 'ar', child: Text('AR')),
                              ],
                              onChanged: (val) {
                                if (val != null) themeProvider.setLanguage(val);
                              },
                            ),
                          ),
                        ),
                        // Theme Toggle
                        IconButton(
                          onPressed: themeProvider.toggleTheme,
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.yellow : Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.white10 : Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                     // LOGO
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 28, // Slightly smaller
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF1E2E4F).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us and start saving',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedInputField(
                      labelText: 'Full Name',
                      controller: _fullNameController,
                      prefixIcon: _iconForField('Full Name', isDark),
                    ),
                    const SizedBox(height: 20),
                    AnimatedInputField(
                      labelText: 'Email',
                      controller: _emailController,
                      prefixIcon: _iconForField('Email', isDark),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    AnimatedInputField(
                      labelText: 'Password',
                      controller: _passwordController,
                      prefixIcon: _iconForField('Password', isDark),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AnimatedInputField(
                      labelText: 'Confirm Password',
                      controller: _confirmController,
                      prefixIcon: _iconForField('Confirm Password', isDark),
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _buttonScaleAnim,
                      child: GestureDetector(
                        onTapDown: _onButtonTapDown,
                        onTapUp: _onButtonTapUp,
                        onTapCancel: _onButtonTapCancel,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF69B39C), // Teal
                                Color(0xFF1E2E4F), // Navy
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF69B39C).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
