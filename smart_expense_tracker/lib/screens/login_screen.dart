import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _buttonAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeOut));
  }

  void _onButtonTapDown(TapDownDetails _) {
    _buttonAnimController.forward();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter email and password'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      // Navigation will be handled by AuthGate automatically
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') msg = 'No user found for that email';
      if (e.code == 'wrong-password') msg = 'Wrong password provided';
      if (e.code == 'invalid-credential') msg = 'Invalid email or password';
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
    _buttonAnimController.reverse();
    if (!_loading) {
      _signIn();
    }
  }

  void _onButtonTapCancel() {
    _buttonAnimController.reverse();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFF6B73FF)
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(color: Colors.white),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 1.0,
            child: AbstractBackground(colors: gradientColors),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            color: Colors.teal.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedInputField(
                      labelText: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      onTap: () => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    AnimatedInputField(
                      labelText: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signIn(),
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
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.4),
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
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      letterSpacing: 1.1),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Color(0xFF667eea),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
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
