import 'package:flutter/material.dart';
import '../widgets/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    );

    // Pulse animation: 1.0 -> 1.1 -> 1.0 (Seamless start)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_controller);

    // Glow fades in and out
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthGate(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2E4F), // Navy Background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ScaleTransition(
              scale: _scaleAnimation,
                child: Container( // Container to apply shadow to the image's extent
                  width: 200, // Make container larger to ensure logo and glow fit
                  height: 200,
                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF69B39C).withOpacity(0.8 * _glowAnimation.value), // Stronger teal glow
                                          blurRadius: 70 * _glowAnimation.value, // More blur
                                          spreadRadius: 20 * _glowAnimation.value, // More spread
                                          offset: const Offset(0, 0), // All around
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF1E2E4F).withOpacity(0.1 * _glowAnimation.value), // Very subtle navy secondary glow
                                          blurRadius: 30 * _glowAnimation.value,
                                          spreadRadius: 5 * _glowAnimation.value,
                                          offset: const Offset(0, 0), // All around
                                        ),
                                      ],                  ),
                  child: Center( // Center the image within this container
                    child: Image.asset(
                      'assets/images/logo.png',
                      // No explicit width/height here to let it scale naturally within Center/Container
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            );
          },
        ),
      ),
    );
  }
}
