import 'package:flutter/material.dart';
import '../utils/ios_colors.dart';

class IOSFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? badgeText;
  final bool isSecondary;
  final String? tooltip;

  const IOSFloatingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.badgeText,
    this.isSecondary = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSecondary ? IOSColors.secondaryGradient : IOSColors.mainGradient,
        boxShadow: [
          BoxShadow(
            color: (isSecondary ? IOSColors.accentBlue : IOSColors.primaryPurple).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Botón principal
            InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            // Badge
            if (badgeText != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar múltiples botones flotantes
class IOSFloatingButtonGroup extends StatelessWidget {
  final List<IOSFloatingButton> buttons;
  final double spacing;

  const IOSFloatingButtonGroup({
    super.key,
    required this.buttons,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((button) {
        final isLast = buttons.last == button;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: button,
        );
      }).toList(),
    );
  }
}
