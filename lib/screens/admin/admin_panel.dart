import 'package:flutter/material.dart';
import 'register_doctor_screen.dart';
import 'register_patient_screen.dart';
import 'view_doctors_screen.dart';
import 'view_patients_screen.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implementar logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildMenuCard(
            context,
            'Registrar Doctor',
            Icons.person_add,
            Colors.blue,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterDoctorScreen())),
          ),
          _buildMenuCard(
            context,
            'Registrar Paciente',
            Icons.personal_injury,
            Colors.green,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterPatientScreen())),
          ),
          _buildMenuCard(
            context,
            'Ver Doctores',
            Icons.people,
            Colors.orange,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ViewDoctorsScreen())),
          ),
          _buildMenuCard(
            context,
            'Ver Pacientes',
            Icons.group,
            Colors.purple,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ViewPatientsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
