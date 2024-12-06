import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignDoctorsScreen extends StatefulWidget {
  const AssignDoctorsScreen({Key? key}) : super(key: key);

  @override
  State<AssignDoctorsScreen> createState() => _AssignDoctorsScreenState();
}

class _AssignDoctorsScreenState extends State<AssignDoctorsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedPatient;
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
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> patientItems = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['name'] ?? 'Sin nombre'),
                      );
                    })
                    .toList();

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Paciente',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPatient,
                  items: patientItems,
                  onChanged: (value) {
                    setState(() {
                      selectedPatient = value;
                      selectedDoctors.clear();
                    });
                    _loadCurrentDoctors(value!);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Lista de Doctores
            Expanded(
              child: selectedPatient == null
                  ? const Center(
                      child: Text('Seleccione un paciente primero'),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('doctors').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            
                            return CheckboxListTile(
                              title: Text(data['name'] ?? 'Sin nombre'),
                              subtitle: Text(data['specialty'] ?? 'Sin especialidad'),
                              value: selectedDoctors[doc.id] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedDoctors[doc.id] = value ?? false;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
            // Botón de guardar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: selectedPatient == null ? null : _saveAssignments,
              child: const Text('Guardar Asignaciones'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCurrentDoctors(String patientId) async {
    try {
      final assignments = await _firestore
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
    if (selectedPatient == null) return;

    try {
      // Iniciar transacción
      await _firestore.runTransaction((transaction) async {
        // Obtener asignaciones actuales
        final currentAssignments = await _firestore
            .collection('doctor_patients')
            .where('patientId', isEqualTo: selectedPatient)
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
              'patientId': selectedPatient,
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
