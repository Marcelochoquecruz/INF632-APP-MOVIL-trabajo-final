import 'package:flutter/material.dart';

class IOSColors {
  // Degradado principal para botones y barras de navegación
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A00E0), // Morado fuerte
      Color(0xFF8E2DE2), // Morado suave
      Color(0xFF00C9FF), // Azul claro
    ],
  );

  // Degradado para botones secundarios
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8E2DE2), // Morado suave
      Color(0xFF00C9FF), // Azul claro
    ],
  );

  // Degradado para efectos de selección
  static LinearGradient selectedItemGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white.withOpacity(0.2),
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.05),
    ],
  );

  // Colores sólidos
  static const Color primaryPurple = Color(0xFF4A00E0);
  static const Color accentBlue = Color(0xFF00C9FF);
  
  // Sombras y efectos
  static BoxShadow defaultShadow = BoxShadow(
    color: primaryPurple.withOpacity(0.3),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}
