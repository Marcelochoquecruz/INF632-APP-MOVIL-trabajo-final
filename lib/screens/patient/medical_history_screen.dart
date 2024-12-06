import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

      final recordsSnapshot = await _firestore
          .collection('medical_records')
          .where('patientId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final records = await Future.wait(
        recordsSnapshot.docs.map((doc) async {
          final data = doc.data();
          final doctorId = data['doctorId'] as String;
          final doctorDoc = await _firestore.collection('doctors').doc(doctorId).get();
          final doctorName = doctorDoc.data()?['name'] ?? 'Doctor no encontrado';

          return {
            'id': doc.id,
            'date': (data['date'] as Timestamp).toDate(),
            'diagnosis': data['diagnosis'] ?? 'No especificado',
            'treatment': data['treatment'] ?? 'No especificado',
            'notes': data['notes'] ?? '',
            'doctorName': doctorName,
            'prescription': data['prescription'] ?? 'No especificada',
          };
        }),
      );

      setState(() {
        _medicalRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial médico: $e')),
        );
      }
    }
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          DateFormat('dd/MM/yyyy').format(record['date']),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Doctor: ${record['doctorName']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('Diagnóstico', record['diagnosis']),
                const SizedBox(height: 8),
                _buildInfoSection('Tratamiento', record['treatment']),
                const SizedBox(height: 8),
                if (record['prescription'].isNotEmpty)
                  _buildInfoSection('Prescripción', record['prescription']),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Historial Médico'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMedicalHistory,
              child: _medicalRecords.isEmpty
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
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _medicalRecords.length,
                      itemBuilder: (context, index) {
                        return _buildRecordCard(_medicalRecords[index]);
                      },
                    ),
            ),
    );
  }
}
