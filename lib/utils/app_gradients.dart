import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A00E0), // Morado fuerte
      Color(0xFF8E2DE2), // Morado suave
      Color(0xFF00C9FF), // Azul claro
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4A00E0), // Morado fuerte
      Color(0xFF8E2DE2), // Morado suave
      Color(0xFF00C9FF), // Azul claro
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4A00E0), // Morado fuerte
      Color(0xFF8E2DE2), // Morado suave
      Color(0xFF00C9FF), // Azul claro
    ],
  );
}
