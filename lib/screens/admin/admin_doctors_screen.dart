import 'package:flutter/material.dart';
import '../../widgets/ios_button.dart';
import '../../widgets/ios_glass_button.dart';
import 'admin_base_screen.dart';

class AdminDoctorsScreen extends StatelessWidget {
  const AdminDoctorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminBaseScreen(
      title: 'Gestión de Doctores',
      currentIndex: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botones de acción principales
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IOSButton(
                        text: 'Nuevo Doctor',
                        icon: Icons.add,
                        onPressed: () {},
                        width: 180,
                      ),
                      const SizedBox(width: 12),
                      IOSButton(
                        text: 'Importar',
                        icon: Icons.upload_file,
                        isSecondary: true,
                        onPressed: () {},
                        width: 140,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IOSGlassButton(
                        text: 'Filtrar',
                        icon: Icons.filter_list,
                        isSmall: true,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      IOSGlassButton(
                        text: 'Ordenar',
                        icon: Icons.sort,
                        isSmall: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Lista de doctores
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: Text(
                          'Dr${index + 1}',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Dr. Nombre ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Especialidad: Cardiología'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[700],
                              ),
                              const Text(' 4.8 • 150 consultas'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IOSButton(
                            text: 'Editar',
                            icon: Icons.edit,
                            isSmall: true,
                            isOutlined: true,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          IOSButton(
                            text: 'Eliminar',
                            icon: Icons.delete,
                            isSmall: true,
                            isSecondary: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
