class SpecialtyModel {
  final String id;
  final String name;
  final String description;
  final String icon;

  SpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }

  factory SpecialtyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SpecialtyModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
}
