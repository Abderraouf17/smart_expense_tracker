import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../utils/constants.dart'; // Ensure this import is here

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
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;
  
  bool _loading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _buttonAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeOut));
        
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final box = Hive.box('settings');
    setState(() {
      _rememberMe = box.get('rememberMe', defaultValue: false);
      if (_rememberMe) {
        _emailController.text = box.get('savedEmail', defaultValue: '');
        _passwordController.text = box.get('savedPassword', defaultValue: '');
      }
    });
  }

  void _onButtonTapDown(TapDownDetails _) {
    _buttonAnimController.forward();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final l10n = AppLocalizations.of(context)!; // For localized snackbar messages
    
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(l10n.enterEmailPassword, Colors.orange.shade600, Icons.warning);
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Handle Remember Me
      final box = Hive.box('settings');
      await box.put('rememberMe', _rememberMe);
      if (_rememberMe) {
        await box.put('savedEmail', email);
        await box.put('savedPassword', password); // Note: Simple persistence for demo
      } else {
        await box.delete('savedEmail');
        await box.delete('savedPassword');
      }

      if (!mounted) return;
      // Navigation handled by AuthGate
    } on FirebaseAuthException catch (e) {
      String msg = l10n.loginFailed;
      if (e.code == 'user-not-found') msg = l10n.noUserFound;
      if (e.code == 'wrong-password') msg = l10n.wrongPassword;
      if (e.code == 'invalid-credential') msg = l10n.invalidCredentials;
      _showSnackBar(msg, Colors.red.shade600, Icons.error);
    } catch (e) {
      _showSnackBar('${l10n.error}: $e', Colors.red.shade600, Icons.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  
  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
  
  void _scrollToFeatures() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _buttonAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF69B39C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF69B39C), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1E2E4F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    // New Theme Gradients
    final gradientColors = isDark 
      ? [const Color(0xFF121212), const Color(0xFF1E2E4F)] 
      : [
          const Color(0xFF1E2E4F), // Navy
          const Color(0xFF456B9C), // Lighter Navy
          const Color(0xFF69B39C)  // Teal
        ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(color: isDark ? const Color(0xFF121212) : Colors.white),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 1.0,
            child: AbstractBackground(colors: gradientColors),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center align
                  children: [
                    // Top Bar (Settings)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Language Toggle (Simple Button)
                        TextButton.icon(
                          onPressed: () {
                            final newLang = themeProvider.language == 'en' ? 'ar' : 'en';
                            themeProvider.setLanguage(newLang);
                          },
                          icon: Icon(Icons.language, color: isDark ? Colors.white70 : const Color(0xFF1E2E4F)),
                          label: Text(
                            themeProvider.language == 'en' ? l10n.arabic : l10n.english,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E2E4F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: isDark ? Colors.white10 : Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        // Theme Toggle
                        IconButton(
                          onPressed: themeProvider.toggleTheme,
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.amber : const Color(0xFF1E2E4F), // Amber for sun, Navy for moon contrast
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
                      l10n.welcomeBack,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF69B39C).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.manageFinances,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedInputField(
                      labelText: l10n.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.white70 : const Color(0xFF1E2E4F)),
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      onTap: () => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    AnimatedInputField(
                      labelText: l10n.password,
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : const Color(0xFF1E2E4F)),
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signIn(),
                    ),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: isDark ? Colors.tealAccent.shade100 : const Color(0xFF1E2E4F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Remember Me
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF69B39C),
                          onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        ),
                        Text(
                          l10n.rememberMe,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
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
                              colors: [Color(0xFF1E2E4F), Color(0xFF69B39C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E2E4F).withOpacity(0.4),
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
                              : Text(
                                  l10n.login,
                                  style: const TextStyle(
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
                        child: Text(
                          l10n.createAccount,
                          style: TextStyle(
                            color: isDark ? Colors.tealAccent : const Color(0xFF69B39C), // Teal
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    TextButton.icon(
                      onPressed: _scrollToFeatures,
                      icon: Icon(Icons.arrow_downward, color: isDark ? Colors.white70 : Colors.black54),
                      label: Text(
                        l10n.seeFeatures,
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                    
                    // Features Section
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      l10n.whyApp,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E2E4F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _buildFeatureItem(
                      Icons.pie_chart, 
                      l10n.smartAnalytics, 
                      l10n.smartAnalyticsDesc,
                      isDark
                    ),
                    _buildFeatureItem(
                      Icons.account_balance_wallet, 
                      l10n.expenseTracking, 
                      l10n.expenseTrackingDesc,
                      isDark
                    ),
                    _buildFeatureItem(
                      Icons.money_off, 
                      l10n.debtManagement, 
                      l10n.debtManagementDesc,
                      isDark
                    ),
                    _buildFeatureItem(
                      Icons.cloud_sync, 
                      l10n.cloudSync, 
                      l10n.cloudSyncDesc,
                      isDark
                    ),
                    _buildFeatureItem(
                      Icons.dark_mode, 
                      l10n.darkModeFeature, 
                      l10n.darkModeFeatureDesc,
                      isDark
                    ),
                    const SizedBox(height: 50),
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