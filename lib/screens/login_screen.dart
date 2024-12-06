import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_app_bar.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
      return;
    }

    final userType = arguments as UserType;
    final authController = context.read<AuthController>();

    final success = await authController.signIn(
      _emailController.text,
      _passwordController.text,
      userType,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      switch (userType) {
        case UserType.admin:
          Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
          break;
        case UserType.doctor:
          Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
          break;
        case UserType.patient:
          Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
          break;
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null) {
      // Si no hay argumentos, redirigir a la pantalla de inicio
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Center(child: CircularProgressIndicator());
    }

    final userType = arguments as UserType;
    String title;
    Color color;

    switch (userType) {
      case UserType.patient:
        title = 'Paciente';
        color = Colors.blue;
        break;
      case UserType.doctor:
        title = 'Doctor';
        color = Colors.green;
        break;
      case UserType.admin:
        title = 'Administrador';
        color = Colors.purple;
        break;
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Iniciar Sesión',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor ingrese un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                CustomButton(
                  text: 'Iniciar Sesión',
                  onPressed: () => _login(context),
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
