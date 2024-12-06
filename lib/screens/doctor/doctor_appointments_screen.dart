import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _selectedDate = DateTime.now();

  Future<List<Map<String, dynamic>>> _getAppointments() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return [];

    try {
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointmentsQuery = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .orderBy('date')
          .get();

      List<Map<String, dynamic>> appointments = [];
      for (var doc in appointmentsQuery.docs) {
        final data = doc.data();
        final patientId = data['patientId'] as String;
        
        // Obtener datos del paciente de la colección correcta
        final patientDoc = await _firestore.collection('patients').doc(patientId).get();
        
        if (patientDoc.exists) {
          final patientData = patientDoc.data() as Map<String, dynamic>;
          appointments.add({
            'id': doc.id,
            'date': (data['date'] as Timestamp).toDate(),
            'status': data['status'] ?? 'pendiente',
            'patientName': patientData['name'] ?? 'Sin nombre',
            'patientId': patientId,
            'notes': data['notes'] ?? '',
            'reason': data['reason'] ?? 'No especificado',
          });
        }
      }

      return appointments;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar citas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a: $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {}); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Citas'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Seleccionar fecha',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final appointments = snapshot.data ?? [];

                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay citas para ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: appointments.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final date = appointment['date'] as DateTime;
                    final status = appointment['status'] as String;
                    final statusColor = _getStatusColor(status);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor,
                          child: Text(
                            appointment['patientName'].substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          appointment['patientName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Hora: ${DateFormat('HH:mm').format(date)}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String newStatus) {
                            _updateAppointmentStatus(appointment['id'], newStatus);
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'pendiente',
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Pendiente'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'completada',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Completada'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'cancelada',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Cancelada'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Motivo: ${appointment['reason']}'),
                                if (appointment['notes'].isNotEmpty)
                                  Text('Notas: ${appointment['notes']}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Estado actual: $status',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
