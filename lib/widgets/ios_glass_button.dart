import 'package:flutter/material.dart';
import 'dart:ui';

class IOSGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isSmall;
  final double? width;

  const IOSGlassButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isSmall = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: isSmall ? 36 : 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 16 : 24,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: Colors.white,
                        size: isSmall ? 16 : 20,
                      ),
                      SizedBox(width: isSmall ? 6 : 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 14 : 16,
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
