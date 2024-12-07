import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_app_bar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  String _getUserTypeText(UserType type) {
    switch (type) {
      case UserType.patient:
        return 'Paciente';
      case UserType.doctor:
        return 'Doctor';
      case UserType.admin:
        return 'Administrador';
    }
  }

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.patient:
        return Colors.blue;
      case UserType.doctor:
        return Colors.green;
      case UserType.admin:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userType = authController.userType!;
    final email = authController.user?.email ?? 'No disponible';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bienvenido ${_getUserTypeText(userType)}',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la aplicación
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bienvenido/a',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getUserTypeColor(userType),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getUserTypeText(userType),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              '¡Bienvenido!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Has ingresado como ${_getUserTypeText(userType)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Información de la cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Correo: $email'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
