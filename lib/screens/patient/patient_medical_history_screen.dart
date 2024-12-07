import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientMedicalHistoryScreen extends StatefulWidget {
  const PatientMedicalHistoryScreen({super.key});

  @override
  State<PatientMedicalHistoryScreen> createState() => _PatientMedicalHistoryScreenState();
}

class _PatientMedicalHistoryScreenState extends State<PatientMedicalHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _patientData;
  List<Map<String, dynamic>> _medicalRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalHistory();
  }

  Future<void> _loadMedicalHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Cargar datos del paciente
      final patientDoc = await _firestore.collection('patients').doc(userId).get();
      if (!patientDoc.exists) {
        setState(() => _isLoading = false);
        return;
      }

      // Cargar registros médicos
      final recordsQuery = await _firestore
          .collection('medical_records')
          .where('patientId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final records = await Future.wait(
        recordsQuery.docs.map((doc) async {
          final data = doc.data();
          final doctorId = data['doctorId'] as String?;
          String doctorName = 'Doctor no encontrado';

          if (doctorId != null) {
            final doctorDoc = await _firestore.collection('doctors').doc(doctorId).get();
            if (doctorDoc.exists) {
              doctorName = doctorDoc.data()?['name'] ?? 'Doctor no encontrado';
            }
          }

          return {
            'id': doc.id,
            'date': data['date'] as Timestamp,
            'diagnosis': data['diagnosis'] ?? 'No especificado',
            'treatment': data['treatment'] ?? 'No especificado',
            'notes': data['notes'] ?? '',
            'doctorName': doctorName,
          };
        }),
      );

      setState(() {
        _patientData = patientDoc.data();
        _medicalRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Historial Médico'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicalRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay registros médicos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_patientData?['medicalHistory'] != null) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Historial General:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _patientData!['medicalHistory'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _medicalRecords.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final record = _medicalRecords[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          record['doctorName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          record['date'].toDate().toString().split('.')[0],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoSection('Diagnóstico', record['diagnosis']),
                                const SizedBox(height: 8),
                                _buildInfoSection('Tratamiento', record['treatment']),
                                if (record['notes'].isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoSection('Notas', record['notes']),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }
}
