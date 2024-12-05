import 'package:flutter/material.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_card.dart';
import '../../utils/app_colors.dart';
import 'admin_base_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminBaseScreen(
      title: 'Dashboard Administrativo',
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Usuarios',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '1,234',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Doctores Activos',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '48',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Nuevo Usuario',
              onPressed: () {
                // Acción del botón
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
