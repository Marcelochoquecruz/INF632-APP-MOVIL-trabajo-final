import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorMedicalRecordsScreen extends StatefulWidget {
  const DoctorMedicalRecordsScreen({super.key});

  @override
  State<DoctorMedicalRecordsScreen> createState() => _DoctorMedicalRecordsScreenState();
}

class _DoctorMedicalRecordsScreenState extends State<DoctorMedicalRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _loadPatients() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return [];

    // Obtener los pacientes asignados al doctor
    final assignedPatientsSnapshot = await _firestore
        .collection('doctor_patients')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    // Obtener los IDs de los pacientes
    final patientIds = assignedPatientsSnapshot.docs.map((doc) => doc.get('patientId') as String).toList();

    if (patientIds.isEmpty) return [];

    // Obtener los datos de los pacientes
    final patientsData = await Future.wait(
      patientIds.map((patientId) async {
        final patientDoc = await _firestore.collection('patients').doc(patientId).get();
        if (!patientDoc.exists) return null;
        
        final data = patientDoc.data()!;
        return {
          'id': patientId,
          'name': data['name'] ?? 'Sin nombre',
          'medicalHistory': data['medicalHistory'] ?? 'Sin historial médico',
          'gender': data['gender'] ?? 'No especificado',
          'emergencyPhone': data['emergencyPhone'] ?? 'No especificado',
        };
      }),
    );

    return patientsData.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> _updateMedicalHistory(String patientId, String currentHistory) async {
    final TextEditingController historyController = TextEditingController(text: currentHistory);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Historial Médico'),
        content: TextField(
          controller: historyController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Ingrese el historial médico actualizado',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('patients').doc(patientId).update({
                  'medicalHistory': historyController.text,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Historial médico actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historiales Médicos'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final patients = snapshot.data ?? [];

          if (patients.isEmpty) {
            return const Center(
              child: Text('No tienes pacientes asignados'),
            );
          }

          return ListView.builder(
            itemCount: patients.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ExpansionTile(
                  title: Text(
                    patient['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Género: ${patient['gender']} | Tel. Emergencia: ${patient['emergencyPhone']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Historial Médico:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _updateMedicalHistory(
                                  patient['id'],
                                  patient['medicalHistory'],
                                ),
                                tooltip: 'Editar historial',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            patient['medicalHistory'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
