import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

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
    final authController = context.watch<AuthController>();
    final userType = authController.userType!;
    final email = authController.user?.email ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido ${_getUserTypeText(userType)}'),
        backgroundColor: _getUserTypeColor(userType),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
      ),
    );
  }
}
