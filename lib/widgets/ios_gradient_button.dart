import 'package:flutter/material.dart';

class IOSGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isSmall;

  const IOSGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSmall ? 36 : 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmall ? 18 : 25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A00E0), // Morado fuerte
            Color(0xFF8E2DE2), // Morado suave
            Color(0xFF00C9FF), // Azul claro
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isSmall ? 18 : 25),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
              vertical: isSmall ? 8 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmall ? 18 : 25),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
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
    );
  }
}
