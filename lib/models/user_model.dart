class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'doctor' or 'patient'
  final String? specialty; // Solo para doctores
  final String? licenseNumber; // Solo para doctores
  final String? profileImageUrl;
  final int? age; // Edad del usuario
  final String? birthPlace; // Lugar de nacimiento
  final String? medicalConditions; // Padecimientos médicos
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.specialty,
    this.licenseNumber,
    this.profileImageUrl,
    this.age,
    this.birthPlace,
    this.medicalConditions,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      specialty: map['specialty'],
      licenseNumber: map['licenseNumber'],
      profileImageUrl: map['profileImageUrl'],
      age: map['age'],
      birthPlace: map['birthPlace'],
      medicalConditions: map['medicalConditions'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'birthPlace': birthPlace,
      'medicalConditions': medicalConditions,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? specialty,
    String? licenseNumber,
    String? profileImageUrl,
    int? age,
    String? birthPlace,
    String? medicalConditions,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      birthPlace: birthPlace ?? this.birthPlace,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
