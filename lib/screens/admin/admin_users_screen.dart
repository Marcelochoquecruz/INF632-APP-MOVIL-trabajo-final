import 'package:flutter/material.dart';
import '../../widgets/ios_button.dart';
import 'admin_base_screen.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminBaseScreen(
      title: 'Gestión de Usuarios',
      currentIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: IOSButton(
                    text: 'Nuevo Usuario',
                    icon: Icons.add,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                IOSButton(
                  text: 'Filtrar',
                  icon: Icons.filter_list,
                  isSecondary: true,
                  isSmall: true,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Lista de usuarios con botones de acción
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Usuario ${index + 1}'),
                    subtitle: const Text('usuario@email.com'),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
