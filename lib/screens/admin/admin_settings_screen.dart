import 'package:flutter/material.dart';
import '../../widgets/ios_button.dart';
import '../../widgets/ios_glass_button.dart';
import '../../widgets/ios_animated_button.dart';
import '../../widgets/ios_floating_button.dart';
import 'admin_base_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return AdminBaseScreen(
      title: 'Configuración',
      currentIndex: 3,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Botones con Gradiente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    IOSButton(
                      text: 'Principal',
                      icon: Icons.settings,
                      onPressed: () {},
                    ),
                    IOSButton(
                      text: 'Secundario',
                      icon: Icons.person,
                      isSecondary: true,
                      onPressed: () {},
                    ),
                    IOSButton(
                      text: 'Con Borde',
                      icon: Icons.edit,
                      isOutlined: true,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Botones de Cristal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.2),
                        Colors.blue.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      IOSGlassButton(
                        text: 'Filtrar',
                        icon: Icons.filter_list,
                        onPressed: () {},
                      ),
                      IOSGlassButton(
                        text: 'Ordenar',
                        icon: Icons.sort,
                        isSmall: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Botones Animados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    IOSAnimatedButton(
                      text: 'Guardar Cambios',
                      icon: Icons.save,
                      onPressed: _simulateLoading,
                    ),
                    IOSAnimatedButton(
                      text: 'Sincronizar',
                      icon: Icons.sync,
                      isSecondary: true,
                      onPressed: _simulateLoading,
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Espacio para los botones flotantes
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IOSFloatingButtonGroup(
              buttons: [
                IOSFloatingButton(
                  icon: Icons.notifications,
                  badgeText: '3',
                  onPressed: () {},
                ),
                IOSFloatingButton(
                  icon: Icons.message,
                  badgeText: '5',
                  isSecondary: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
