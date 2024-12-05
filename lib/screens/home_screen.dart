import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                const SizedBox(height: 30),
                
                // Título
                const Text(
                  'Sistema de Consultas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                
                // Botones
                CustomButton(
                  text: 'Ingresar como Paciente',
                  onPressed: () => _navigateToLogin(context, UserType.patient),
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                
                CustomButton(
                  text: 'Ingresar como Doctor',
                  onPressed: () => _navigateToLogin(context, UserType.doctor),
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                
                CustomButton(
                  text: 'Ingresar como Administrador',
                  onPressed: () => _navigateToLogin(context, UserType.admin),
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserType type) {
    Navigator.pushNamed(
      context,
      '/login',
      arguments: type,
    );
  }
}
