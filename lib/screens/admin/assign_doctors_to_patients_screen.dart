import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignDoctorsToPatients extends StatefulWidget {
  const AssignDoctorsToPatients({super.key});

  @override
  State<AssignDoctorsToPatients> createState() => _AssignDoctorsToPatientsState();
}

class _AssignDoctorsToPatientsState extends State<AssignDoctorsToPatients> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedPatientId;
  Map<String, bool> selectedDoctors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Doctores a Pacientes'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de Paciente
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('patients').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final patients = snapshot.data!.docs;
                List<DropdownMenuItem<String>> patientItems = patients.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text(data['name'] ?? 'Sin nombre'),
                  );
                }).toList();

                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar Paciente',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedPatientId,
                      items: patientItems,
                      onChanged: (value) {
                        setState(() {
                          selectedPatientId = value;
                          selectedDoctors.clear();
                        });
                        if (value != null) {
                          _loadAssignedDoctors(value);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Lista de Doctores
            Expanded(
              child: selectedPatientId == null
                  ? const Center(
                      child: Text(
                        'Seleccione un paciente para ver los doctores disponibles',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Card(
                      elevation: 4,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('doctors').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final doctors = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              final data = doctor.data() as Map<String, dynamic>;
                              return CheckboxListTile(
                                title: Text(data['name'] ?? 'Sin nombre'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['specialty'] ?? 'Sin especialidad'),
                                    Text(data['email'] ?? 'Sin email'),
                                  ],
                                ),
                                value: selectedDoctors[doctor.id] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedDoctors[doctor.id] = value ?? false;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // Botón de guardar
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar Asignaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: selectedPatientId == null ? null : _saveAssignments,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAssignedDoctors(String patientId) async {
    try {
      final QuerySnapshot assignments = await _firestore
          .collection('doctor_patients')
          .where('patientId', isEqualTo: patientId)
          .get();

      setState(() {
        selectedDoctors.clear();
        for (var doc in assignments.docs) {
          selectedDoctors[doc.get('doctorId')] = true;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar doctores asignados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAssignments() async {
    if (selectedPatientId == null) return;

    try {
      await _firestore.runTransaction((transaction) async {
        // Obtener asignaciones actuales
        final currentAssignments = await _firestore
            .collection('doctor_patients')
            .where('patientId', isEqualTo: selectedPatientId)
            .get();

        // Eliminar asignaciones existentes
        for (var doc in currentAssignments.docs) {
          transaction.delete(doc.reference);
        }

        // Crear nuevas asignaciones
        for (var entry in selectedDoctors.entries) {
          if (entry.value) {
            final docRef = _firestore.collection('doctor_patients').doc();
            transaction.set(docRef, {
              'doctorId': entry.key,
              'patientId': selectedPatientId,
              'assignedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asignaciones guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar asignaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
