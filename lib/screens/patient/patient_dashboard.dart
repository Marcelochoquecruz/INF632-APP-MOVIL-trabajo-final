import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'medical_history_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _patientData;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  String? _assignedDoctorName;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
    _loadUpcomingAppointments();
  }

  Future<void> _loadPatientData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Cargar datos del paciente
      final patientDoc = await _firestore.collection('patients').doc(userId).get();
      if (patientDoc.exists) {
        setState(() {
          _patientData = patientDoc.data();
        });

        // Cargar doctores asignados
        final assignmentsSnapshot = await _firestore
            .collection('doctor_patients')
            .where('patientId', isEqualTo: userId)
            .get();

        if (assignmentsSnapshot.docs.isNotEmpty) {
          final doctorIds = assignmentsSnapshot.docs.map((doc) => doc.get('doctorId') as String).toList();
          
          // Obtener el primer doctor asignado (podemos expandir esto más tarde para mostrar todos)
          final doctorDoc = await _firestore.collection('doctors').doc(doctorIds.first).get();
          if (doctorDoc.exists) {
            setState(() {
              _assignedDoctorName = doctorDoc.data()?['name'];
            });
          }
        } else {
          setState(() {
            _assignedDoctorName = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _loadUpcomingAppointments() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: now)
          .orderBy('date')
          .limit(5)
          .get();

      final appointments = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final doctorId = data['doctorId'] as String;
          final doctorDoc = await _firestore.collection('doctors').doc(doctorId).get();
          final doctorName = doctorDoc.data()?['name'] ?? 'Doctor no encontrado';

          return {
            'id': doc.id,
            'date': (data['date'] as Timestamp).toDate(),
            'status': data['status'] ?? 'pendiente',
            'doctorName': doctorName,
            'reason': data['reason'] ?? 'No especificado',
          };
        }),
      );

      setState(() {
        _upcomingAppointments = appointments;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar citas: $e')),
        );
      }
    }
  }

  Widget _buildDoctorCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.medical_services,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            const Text(
              'Doctor Asignado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _assignedDoctorName ?? 'No asignado',
              style: TextStyle(
                fontSize: 16,
                color: _assignedDoctorName != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            const Text(
              'Próximas Citas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _upcomingAppointments.isEmpty 
                ? '0'
                : _upcomingAppointments.length.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final date = appointment['date'] as DateTime;
    final status = appointment['status'] as String;
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completada':
        statusColor = Colors.green;
        break;
      case 'cancelada':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.calendar_today, color: Colors.white),
        ),
        title: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${appointment['doctorName']}'),
            Text('Motivo: ${appointment['reason']}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _patientData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadPatientData();
                await _loadUpcomingAppointments();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido, ${_patientData?['name']}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDoctorCard(),
                          ),
                          Expanded(
                            child: _buildAppointmentsCard(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Próximas Citas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_upcomingAppointments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes citas programadas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...(_upcomingAppointments.map(_buildAppointmentCard).toList()),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicalHistoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Ver Historial Médico',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implementar solicitud de cita
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Próximamente: Solicitud de citas'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Solicitar Nueva Cita',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
