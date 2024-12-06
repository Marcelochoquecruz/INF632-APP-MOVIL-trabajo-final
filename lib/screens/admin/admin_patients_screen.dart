import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/ios_button.dart';
import '../../widgets/ios_glass_button.dart';
import 'admin_base_screen.dart';

class AdminPatientsScreen extends StatefulWidget {
  const AdminPatientsScreen({Key? key}) : super(key: key);

  @override
  _AdminPatientsScreenState createState() => _AdminPatientsScreenState();
}

class _AdminPatientsScreenState extends State<AdminPatientsScreen> {
  Future<void> _deletePatient(BuildContext context, String patientId) async {
    // Mostrar diálogo de confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Está seguro que desea eliminar este paciente? Esta acción no se puede deshacer.'),
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

    if (confirm != true) return;

    try {
      // Start a batch write
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      // Delete from patients collection
      batch.delete(FirebaseFirestore.instance.collection('patients').doc(patientId));
      
      // Delete related appointments
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      
      for (var doc in appointmentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete related doctor_patients
      QuerySnapshot doctorPatientsSnapshot = await FirebaseFirestore.instance
          .collection('doctor_patients')
          .where('patientId', isEqualTo: patientId)
          .get();
      
      for (var doc in doctorPatientsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete related medical records
      QuerySnapshot medicalRecordsSnapshot = await FirebaseFirestore.instance
          .collection('medical_records')
          .where('patientId', isEqualTo: patientId)
          .get();
      
      for (var doc in medicalRecordsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit the batch
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente y registros relacionados eliminados correctamente'),
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

  Future<void> _editPatient(BuildContext context, DocumentSnapshot patient) async {
    final nameController = TextEditingController(text: patient['name']);
    final emailController = TextEditingController(text: patient['email']);
    final phoneController = TextEditingController(text: patient['phone'] ?? '');
    final addressController = TextEditingController(text: patient['address'] ?? '');
    final bloodTypeController = TextEditingController(text: patient['bloodType'] ?? '');
    final emergencyContactController = TextEditingController(text: patient['emergencyContact'] ?? '');
    final emergencyPhoneController = TextEditingController(text: patient['emergencyPhone'] ?? '');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Paciente'),
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
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bloodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Sangre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emergencyContactController,
                  decoration: const InputDecoration(
                    labelText: 'Contacto de Emergencia',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emergencyPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono de Emergencia',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(patient.id)
                      .update({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'address': addressController.text,
                    'bloodType': bloodTypeController.text,
                    'emergencyContact': emergencyContactController.text,
                    'emergencyPhone': emergencyPhoneController.text,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paciente actualizado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
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
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    // Dispose of controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bloodTypeController.dispose();
    emergencyContactController.dispose();
    emergencyPhoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminBaseScreen(
      title: 'Gestión de Pacientes',
      currentIndex: 3,
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
                        text: 'Nuevo Paciente',
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Lista de pacientes
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
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

                final patients = snapshot.data!.docs;

                if (patients.isEmpty) {
                  return const Center(
                    child: Text('No hay pacientes registrados'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    final patientData = patient.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            patientData['name']?.substring(0, 1).toUpperCase() ?? 'P',
                          ),
                        ),
                        title: Text(patientData['name'] ?? 'Sin nombre'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patientData['email'] ?? 'Sin email'),
                            Text('Tipo de sangre: ${patientData['bloodType'] ?? 'No especificado'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editPatient(context, patient),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePatient(context, patient.id),
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
