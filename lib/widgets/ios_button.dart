import 'package:flutter/material.dart';
import '../utils/ios_colors.dart';

class IOSButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isSmall;
  final bool isOutlined;
  final double? width;

  const IOSButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isSmall = false,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: isSmall ? 36 : 48,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : (isSecondary ? IOSColors.secondaryGradient : IOSColors.mainGradient),
        borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
        border: isOutlined
            ? Border.all(
                color: IOSColors.primaryPurple,
                width: 2,
              )
            : null,
        boxShadow: isOutlined
            ? null
            : [IOSColors.defaultShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
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
                    color: isOutlined ? IOSColors.primaryPurple : Colors.white,
                    size: isSmall ? 16 : 20,
                  ),
                  SizedBox(width: isSmall ? 6 : 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: isOutlined ? IOSColors.primaryPurple : Colors.white,
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
