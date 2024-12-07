import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/ios_colors.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A00E0), // Morado fuerte
            Color(0xFF8E2DE2), // Morado suave
            Color(0xFF00C9FF), // Azul claro
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0),
                _buildNavItem(Icons.people_outline, Icons.people, 'Usuarios', 1),
                _buildNavItem(Icons.medical_services_outlined, Icons.medical_services, 'Doctores', 2),
                _buildNavItem(Icons.settings_outlined, Icons.settings, 'Ajustes', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? IOSColors.selectedItemGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? filledIcon : outlinedIcon,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}
