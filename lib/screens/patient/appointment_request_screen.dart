import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';

class AppointmentRequestScreen extends StatefulWidget {
  const AppointmentRequestScreen({super.key});

  @override
  State<AppointmentRequestScreen> createState() => _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _notificationService = NotificationService();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDoctor;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final querySnapshot = await _firestore.collection('doctors').get();
      setState(() {
        _doctors = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.data()['name'] ?? 'Sin nombre',
                })
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar doctores: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _requestAppointment() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedDoctor == null ||
        _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Crear la fecha completa
      final appointmentDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Guardar la cita
      await _firestore.collection('appointments').add({
        'patientId': userId,
        'doctorId': _selectedDoctor,
        'date': Timestamp.fromDate(appointmentDate),
        'reason': _reasonController.text,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      // Programar notificación local
      await _notificationService.scheduleNotification(
        title: 'Recordatorio de Cita Médica',
        body: 'Tienes una cita médica mañana a las ${_selectedTime!.format(context)}',
        scheduledDate: appointmentDate.subtract(const Duration(days: 1)),
      );

      // Mostrar notificación inmediata
      await _notificationService.showNotification(
        title: 'Cita Solicitada',
        body: 'Tu solicitud de cita ha sido enviada y está pendiente de confirmación',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud de cita enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Cita'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selector de Doctor
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Doctor',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDoctor,
                    items: _doctors.map((doctor) {
                      return DropdownMenuItem<String>(  // Explicitly specify <String>
                        value: doctor['id'].toString(),  // Convert to string if needed
                        child: Text(doctor['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selector de Fecha
                  ListTile(
                    title: Text(
                      _selectedDate == null
                          ? 'Seleccionar Fecha'
                          : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),

                  // Selector de Hora
                  ListTile(
                    title: Text(
                      _selectedTime == null
                          ? 'Seleccionar Hora'
                          : 'Hora: ${_selectedTime!.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onTap: _selectTime,
                  ),
                  const SizedBox(height: 16),

                  // Campo de Motivo
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de la consulta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de Solicitar
                  ElevatedButton(
                    onPressed: _requestAppointment,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Solicitar Cita',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
