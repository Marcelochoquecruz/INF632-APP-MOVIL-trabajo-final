class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType; // 'patient' o 'doctor'
  final String? specialtyId; // Solo para doctores
  final String? location; // Solo para doctores
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    this.specialtyId,
    this.location,
    this.profileImage,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'specialtyId': specialtyId,
      'location': location,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      userType: map['userType'] ?? 'patient',
      specialtyId: map['specialtyId'],
      location: map['location'],
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}
