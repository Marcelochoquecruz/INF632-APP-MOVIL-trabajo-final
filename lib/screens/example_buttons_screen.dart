import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ios_gradient_button.dart';
import '../widgets/gradient_background.dart';

class ExampleButtonsScreen extends StatelessWidget {
  const ExampleButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botones con Gradiente'),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Botones Grandes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Botón Principal',
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              IOSGradientButton(
                text: 'Botón con Icono',
                icon: Icons.add,
                onPressed: () {},
              ),
              const SizedBox(height: 32),
              const Text(
                'Botones Pequeños',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  IOSGradientButton(
                    text: 'Editar',
                    icon: Icons.edit,
                    isSmall: true,
                    onPressed: () {},
                  ),
                  IOSGradientButton(
                    text: 'Eliminar',
                    icon: Icons.delete,
                    isSmall: true,
                    onPressed: () {},
                  ),
                  IOSGradientButton(
                    text: 'Compartir',
                    icon: Icons.share,
                    isSmall: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
