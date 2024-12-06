import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_doctors_screen.dart';
import 'admin_patients_screen.dart';
import 'assign_doctors_to_patients_screen.dart';
import 'assign_schedules_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contador de Doctores y Pacientes
            Row(
              children: [
                Expanded(
                  child: _buildCountCard(
                    count: '3',
                    label: 'Doctores',
                    color: Colors.blue.shade50,
                    textColor: Colors.blue,
                    icon: Icons.medical_services,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCountCard(
                    count: '2',
                    label: 'Pacientes',
                    color: Colors.green.shade50,
                    textColor: Colors.green,
                    icon: Icons.people,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Gestión',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              padding: const EdgeInsets.all(8),
              children: [
                _buildActionCard(
                  context,
                  'Registrar Doctor',
                  Icons.person_add,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDoctorsScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Registrar Paciente',
                  Icons.person_add,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPatientsScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Ver Doctores',
                  Icons.people,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDoctorsScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Ver Pacientes',
                  Icons.people,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPatientsScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Asignar Doctores',
                  Icons.assignment_ind,
                  Colors.indigo,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssignDoctorsToPatients(),
                    ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Asignar Horarios',
                  Icons.schedule,
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssignSchedulesScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard({
    required String count,
    required String label,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    return Card(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
