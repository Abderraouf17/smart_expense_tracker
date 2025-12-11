import 'package:flutter/material.dart';

// Common Gradient Button with animation for tap
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final double borderRadius;
  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.borderRadius = 30,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    super.initState();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.last.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Background with soft abstract shapes for Login & SignUp
class AbstractBackground extends StatelessWidget {
  final List<Color> colors;
  const AbstractBackground({Key? key, required this.colors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AbstractPainter(colors),
      child: Container(),
    );
  }
}

class _AbstractPainter extends CustomPainter {
  final List<Color> colors;
  _AbstractPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw some soft gradient blobs
    var center1 = Offset(size.width * 0.3, size.height * 0.3);
    var center2 = Offset(size.width * 0.7, size.height * 0.7);
    var center3 = Offset(size.width * 0.8, size.height * 0.2);

    paint.shader = const RadialGradient(
      colors: [Colors.white24, Colors.transparent],
    ).createShader(Rect.fromCircle(center: center1, radius: 150));
    canvas.drawCircle(center1, 150, paint);

    paint.shader = RadialGradient(
      colors: [colors[1].withOpacity(0.3), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center2, radius: 120));
    canvas.drawCircle(center2, 120, paint);

    paint.shader = RadialGradient(
      colors: [colors[2].withOpacity(0.3), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center3, radius: 100));
    canvas.drawCircle(center3, 100, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Input field with soft shadow, rounded corners, and focus glow animation
class AnimatedInputField extends StatefulWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  const AnimatedInputField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  FocusNode? _internalFocusNode;
  bool _hasFocus = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AnimatedInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      if (widget.focusNode == null && _internalFocusNode == null) {
        _internalFocusNode = FocusNode();
      }
      _effectiveFocusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: color, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          if (_hasFocus)
            BoxShadow(
              color: Colors.teal.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        focusNode: _effectiveFocusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          hintText: widget.labelText,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          focusedBorder: _border(Colors.teal),
          enabledBorder: _border(isDark ? Colors.grey.shade600 : Colors.grey.shade300),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}

// Bounce animation floating button
class BounceFloatingButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const BounceFloatingButton({Key? key, required this.icon, required this.onPressed})
      : super(key: key);

  @override
  State<BounceFloatingButton> createState() => _BounceFloatingButtonState();
}

class _BounceFloatingButtonState extends State<BounceFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _bounceAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -15.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(period: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: Colors.teal,
            elevation: 6,
            child: Icon(widget.icon),
          ),
        );
      },
    );
  }
}

// Bottom Navigation Bar with animated icons and page transition placeholder
class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onTap;
  const BottomNavBar({Key? key, this.selectedIndex = 0, this.onTap}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  final List<IconData> icons = const [
    Icons.home_outlined,
    Icons.list_alt_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.bar_chart_outlined,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _controllers = List.generate(
        icons.length,
        (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 200)));
    _scaleAnimations = _controllers
        .map((c) =>
            Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _controllers[_selectedIndex].forward();
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controllers[_selectedIndex].reverse();
      _selectedIndex = widget.selectedIndex;
      _controllers[_selectedIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;
    
    // Use custom onTap if provided, otherwise use default navigation
    if (widget.onTap != null) {
      widget.onTap!(index);
    } else {
      // Default navigation placeholder
      switch (index) {
        case 0:
          // Home screen
          break;
        case 1:
          // Expenses screen
          break;
        case 2:
          // Debt screen
          break;
        case 3:
          // Analytics screen not implemented
          break;
        case 4:
          // Profile screen
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: List.generate(icons.length, (index) {
        return BottomNavigationBarItem(
          icon: ScaleTransition(
            scale: _scaleAnimations[index],
            child: Icon(
              icons[index],
              color: index == _selectedIndex
                  ? Colors.teal.shade700
                  : Colors.grey.shade400,
            ),
          ),
          label: '',
        );
      }),
    );
  }
}
