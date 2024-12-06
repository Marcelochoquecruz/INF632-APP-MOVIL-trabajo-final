import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/ios_button.dart';
import '../../widgets/ios_glass_button.dart';
import 'admin_base_screen.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  _AdminDoctorsScreenState createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  Map<String, dynamic>? updatedDoctorData;

  Future<void> _deleteDoctor(BuildContext context, String doctorId) async {
    try {
      // Mostrar diálogo de confirmación
      bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Está seguro que desea eliminar este doctor? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) return;

      // Eliminar doctor y registros relacionados
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Obtener referencias a documentos relacionados
        final doctorRef = FirebaseFirestore.instance.collection('doctors').doc(doctorId);
        final appointmentsQuery = await FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();
        final doctorPatientsQuery = await FirebaseFirestore.instance
            .collection('doctor_patients')
            .where('doctorId', isEqualTo: doctorId)
            .get();

        // Eliminar doctor
        transaction.delete(doctorRef);

        // Eliminar citas relacionadas
        for (var doc in appointmentsQuery.docs) {
          transaction.delete(doc.reference);
        }

        // Eliminar asignaciones doctor-paciente
        for (var doc in doctorPatientsQuery.docs) {
          transaction.delete(doc.reference);
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editDoctor(BuildContext context, DocumentSnapshot doctor) async {
    final nameController = TextEditingController(text: doctor['name']);
    final specialtyController = TextEditingController(text: doctor['specialty']);
    final phoneController = TextEditingController(text: doctor['phone'] ?? '');
    final emailController = TextEditingController(text: doctor['email']);

    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Doctor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctor.id)
            .update({
          'name': nameController.text.trim(),
          'specialty': specialtyController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Dispose controllers
    nameController.dispose();
    specialtyController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }

  Future<void> _assignPatients(BuildContext context, String doctorId, String doctorName) async {
    try {
      // Obtener todos los pacientes
      final QuerySnapshot patientsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .get();

      // Obtener pacientes ya asignados
      final QuerySnapshot assignedPatientsSnapshot = await FirebaseFirestore.instance
          .collection('doctor_patients')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final List<String> assignedPatientIds = assignedPatientsSnapshot.docs
          .map((doc) => doc.get('patientId') as String)
          .toList();

      Map<String, bool> selectedPatients = {};
      for (var patient in patientsSnapshot.docs) {
        selectedPatients[patient.id] = assignedPatientIds.contains(patient.id);
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Asignar Pacientes al Dr. $doctorName'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView.builder(
                    itemCount: patientsSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      final patient = patientsSnapshot.docs[index];
                      final patientData = patient.data() as Map<String, dynamic>;
                      
                      return CheckboxListTile(
                        title: Text(patientData['name'] ?? 'Sin nombre'),
                        subtitle: Text(patientData['email'] ?? ''),
                        value: selectedPatients[patient.id] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPatients[patient.id] = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        // Iniciar transacción
                        await FirebaseFirestore.instance.runTransaction((transaction) async {
                          // Eliminar asignaciones existentes
                          for (var doc in assignedPatientsSnapshot.docs) {
                            transaction.delete(doc.reference);
                          }

                          // Crear nuevas asignaciones
                          for (var entry in selectedPatients.entries) {
                            if (entry.value) {
                              final docRef = FirebaseFirestore.instance
                                  .collection('doctor_patients')
                                  .doc();
                              transaction.set(docRef, {
                                'doctorId': doctorId,
                                'patientId': entry.key,
                                'assignedAt': FieldValue.serverTimestamp(),
                              });
                            }
                          }
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pacientes asignados correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al asignar pacientes: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final doctors = snapshot.data!.docs;

                if (doctors.isEmpty) {
                  return const Center(
                    child: Text('No hay doctores registrados'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    final doctorData = doctor.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            doctorData['name']?.substring(0, 1).toUpperCase() ?? 'D',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(doctorData['name'] ?? 'Sin nombre'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctorData['specialty'] ?? 'Sin especialidad'),
                            Text(doctorData['email'] ?? 'Sin email'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.group_add),
                              onPressed: () => _assignPatients(
                                context,
                                doctor.id,
                                doctorData['name'] ?? 'Sin nombre',
                              ),
                              tooltip: 'Asignar Pacientes',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editDoctor(context, doctor),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDoctor(context, doctor.id),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
