import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPatientsScreen extends StatefulWidget {
  const ViewPatientsScreen({super.key});

  @override
  State<ViewPatientsScreen> createState() => _ViewPatientsScreenState();
}

class _ViewPatientsScreenState extends State<ViewPatientsScreen> {
  String _searchQuery = '';
  String? _selectedBloodType;
  bool _isAscending = true;
  String _sortField = 'name';
  final List<String> _bloodTypes = [
    'Todos',
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
            },
            tooltip: _isAscending ? 'Ordenar descendente' : 'Ordenar ascendente',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar por',
            onSelected: (String value) {
              setState(() {
                _sortField = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Nombre'),
              ),
              const PopupMenuItem<String>(
                value: 'bloodType',
                child: Text('Tipo de Sangre'),
              ),
              const PopupMenuItem<String>(
                value: 'createdAt',
                child: Text('Fecha de registro'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar paciente...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filtrar por tipo de sangre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  value: _selectedBloodType,
                  items: _bloodTypes
                      .map((type) => DropdownMenuItem(
                            value: type == 'Todos' ? null : type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodType = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'].toString().toLowerCase();
                  final bloodType = data['bloodType'].toString().toLowerCase();
                  final searchLower = _searchQuery.toLowerCase();

                  final matchesSearch = name.contains(searchLower) ||
                      bloodType.contains(searchLower);
                  final matchesBloodType = _selectedBloodType == null ||
                      data['bloodType'] == _selectedBloodType;

                  return matchesSearch && matchesBloodType;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron pacientes'),
                  );
                }

                // Ordenar la lista
                filteredDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  
                  if (_sortField == 'createdAt') {
                    final aDate = (aData['createdAt'] as Timestamp).toDate();
                    final bDate = (bData['createdAt'] as Timestamp).toDate();
                    return _isAscending
                        ? aDate.compareTo(bDate)
                        : bDate.compareTo(aDate);
                  }
                  
                  final aValue = aData[_sortField].toString();
                  final bValue = bData[_sortField].toString();
                  return _isAscending
                      ? aValue.compareTo(bValue)
                      : bValue.compareTo(aValue);
                });

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    final createdAt =
                        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final birthDate =
                        (data['birthDate'] as Timestamp?)?.toDate() ?? DateTime.now();

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            (data['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          data['name'] as String? ?? 'Sin nombre',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Tipo de sangre: ${data['bloodType'] as String? ?? 'No especificado'}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  'Correo',
                                  data['email'] as String? ?? 'No disponible',
                                  Icons.email,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Teléfono',
                                  data['phone'] as String? ?? 'No disponible',
                                  Icons.phone,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Dirección',
                                  data['address'] as String? ?? 'No disponible',
                                  Icons.location_on,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Género',
                                  data['gender'] as String? ?? 'No especificado',
                                  Icons.person,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Fecha de registro',
                                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                  Icons.calendar_today,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Fecha de nacimiento',
                                  '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                                  Icons.cake,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Contacto de emergencia',
                                  data['emergencyContact'] as String? ?? 'No disponible',
                                  Icons.contact_emergency,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Teléfono de emergencia',
                                  data['emergencyPhone'] as String? ?? 'No disponible',
                                  Icons.phone_callback,
                                ),
                                if (data['medicalHistory']?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Antecedentes Médicos:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['medicalHistory'] as String? ?? '',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Editar'),
                                      onPressed: () {
                                        // TODO: Implementar edición
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Eliminar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        // TODO: Implementar eliminación
                                      },
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register-patient');
        },
        tooltip: 'Registrar nuevo paciente',
        child: const Icon(Icons.add),
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    return FirebaseFirestore.instance
        .collection('patients')
        .orderBy(_sortField, descending: !_isAscending)
        .snapshots();
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
