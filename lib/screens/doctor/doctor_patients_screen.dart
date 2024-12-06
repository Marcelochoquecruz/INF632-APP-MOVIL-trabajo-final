import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _getPatients() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return [];

    try {
      // Obtener los pacientes asignados al doctor
      final assignedPatientsQuery = await _firestore
          .collection('doctor_patients')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      List<Map<String, dynamic>> patients = [];
      for (var doc in assignedPatientsQuery.docs) {
        final patientId = doc.data()['patientId'] as String;
        
        // Obtener los datos del paciente
        final patientDoc = await _firestore.collection('patients').doc(patientId).get();
        
        if (patientDoc.exists) {
          final patientData = patientDoc.data() as Map<String, dynamic>;
          
          // Contar las citas del paciente con este doctor
          final appointmentsCount = await _firestore
              .collection('appointments')
              .where('doctorId', isEqualTo: doctorId)
              .where('patientId', isEqualTo: patientId)
              .get();

          patients.add({
            'id': patientId,
            'name': patientData['name'] ?? 'Sin nombre',
            'email': patientData['email'] ?? 'Sin email',
            'phone': patientData['phone'] ?? 'Sin teléfono',
            'appointmentsCount': appointmentsCount.docs.length,
          });
        }
      }

      return patients;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pacientes'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final patients = snapshot.data ?? [];

          if (patients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes pacientes asignados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: patients.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      patient['name'].substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    patient['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${patient['email']}'),
                      Text('Teléfono: ${patient['phone']}'),
                      Text(
                        'Citas totales: ${patient['appointmentsCount']}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.medical_services),
                    onPressed: () {
                      // TODO: Ver historial médico del paciente
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Historial médico en desarrollo'),
                        ),
                      );
                    },
                    tooltip: 'Ver historial médico',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
