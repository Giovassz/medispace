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

  factory SpecialtyModel.fromMap(Map<String, dynamic> map) {
    return SpecialtyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'medical_services',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'icon': icon};
  }

  static List<SpecialtyModel> getDefaultSpecialties() {
    return [
      SpecialtyModel(
        id: '1',
        name: 'Medicina General',
        description: 'Atención médica integral para todas las edades',
        icon: 'medical_services',
      ),
      SpecialtyModel(
        id: '2',
        name: 'Cardiología',
        description: 'Especialista en enfermedades del corazón',
        icon: 'favorite',
      ),
      SpecialtyModel(
        id: '3',
        name: 'Dermatología',
        description: 'Especialista en enfermedades de la piel',
        icon: 'face',
      ),
      SpecialtyModel(
        id: '4',
        name: 'Pediatría',
        description: 'Especialista en medicina infantil',
        icon: 'child_care',
      ),
      SpecialtyModel(
        id: '5',
        name: 'Ginecología',
        description: 'Especialista en salud femenina',
        icon: 'pregnant_woman',
      ),
      SpecialtyModel(
        id: '6',
        name: 'Ortopedia',
        description: 'Especialista en huesos y articulaciones',
        icon: 'accessibility',
      ),
      SpecialtyModel(
        id: '7',
        name: 'Neurología',
        description: 'Especialista en sistema nervioso',
        icon: 'psychology',
      ),
      SpecialtyModel(
        id: '8',
        name: 'Oftalmología',
        description: 'Especialista en ojos y visión',
        icon: 'visibility',
      ),
    ];
  }
}
