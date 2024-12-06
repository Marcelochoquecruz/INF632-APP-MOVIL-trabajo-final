import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignSchedulesScreen extends StatefulWidget {
  const AssignSchedulesScreen({Key? key}) : super(key: key);

  @override
  State<AssignSchedulesScreen> createState() => _AssignSchedulesScreenState();
}

class _AssignSchedulesScreenState extends State<AssignSchedulesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedDoctorId;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<String> selectedDays = [];

  final List<String> daysOfWeek = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Horarios'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de Doctor
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> doctorItems = [];
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  doctorItems.add(DropdownMenuItem(
                    value: doc.id,
                    child: Text('${data['name']} ${data['lastName']}'),
                  ));
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Doctor',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDoctorId,
                  items: doctorItems,
                  onChanged: (value) {
                    setState(() {
                      selectedDoctorId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Selector de Días
            Wrap(
              spacing: 8.0,
              children: daysOfWeek.map((day) {
                final isSelected = selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Selector de Horario
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(startTime?.format(context) ?? 'Hora Inicio'),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          startTime = time;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(endTime?.format(context) ?? 'Hora Fin'),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          endTime = time;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón Guardar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (selectedDoctorId != null && 
                    selectedDays.isNotEmpty && 
                    startTime != null && 
                    endTime != null) {
                  try {
                    await _firestore
                        .collection('doctors')
                        .doc(selectedDoctorId)
                        .collection('schedules')
                        .add({
                      'days': selectedDays,
                      'startTime': '${startTime!.hour}:${startTime!.minute}',
                      'endTime': '${endTime!.hour}:${endTime!.minute}',
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Horario asignado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al asignar horario: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor complete todos los campos'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text(
                'Guardar Horario',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
