import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/consulta_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear una nueva consulta
  Future<String> createConsulta(String title, String description) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'Usuario no autenticado';

      final docRef = await _firestore.collection('consultas').add({
        'userId': user.uid,
        'title': title,
        'description': description,
        'status': 'pendiente',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return docRef.id;
    } catch (e) {
      print('Error al crear consulta: $e');
      rethrow;
    }
  }

  // Obtener todas las consultas del usuario actual
  Stream<List<ConsultaModel>> getConsultas() {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';

    return _firestore
        .collection('consultas')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ConsultaModel.fromMap(
                    doc.data(),
                    doc.id,
                  ))
              .toList();
        });
  }

  // Actualizar el estado de una consulta
  Future<void> updateConsultaStatus(String consultaId, String newStatus) async {
    try {
      await _firestore.collection('consultas').doc(consultaId).update({
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al actualizar estado de consulta: $e');
      rethrow;
    }
  }

  // Eliminar una consulta
  Future<void> deleteConsulta(String consultaId) async {
    try {
      await _firestore.collection('consultas').doc(consultaId).delete();
    } catch (e) {
      print('Error al eliminar consulta: $e');
      rethrow;
    }
  }
}
