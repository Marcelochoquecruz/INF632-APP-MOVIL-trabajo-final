import 'package:flutter/material.dart';
import '../utils/ios_colors.dart';

class IOSAnimatedButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Future<void> Function() onPressed;
  final bool isSecondary;

  const IOSAnimatedButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  State<IOSAnimatedButton> createState() => _IOSAnimatedButtonState();
}

class _IOSAnimatedButtonState extends State<IOSAnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading) return;

    _controller.forward();
    setState(() => _isLoading = true);

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: widget.isSecondary
                ? IOSColors.secondaryGradient
                : IOSColors.mainGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [IOSColors.defaultShadow],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (!_isLoading && widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _isLoading ? 'Cargando...' : widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
