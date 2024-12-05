class ConsultaModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsultaModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = 'pendiente',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ConsultaModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ConsultaModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pendiente',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
