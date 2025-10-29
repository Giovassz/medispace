import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Iniciar sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // Registrar usuario con email y contraseña
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    String? specialty,
    String? licenseNumber,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento de usuario en Firestore
      UserModel userModel = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        specialty: specialty,
        licenseNumber: licenseNumber,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userModel.toMap());

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // Obtener datos del usuario actual
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Error al obtener datos del usuario: $e';
    }
  }

  // Obtener todos los doctores
  Future<List<UserModel>> getDoctors() async {
    try {
      print('🔍 Buscando doctores en Firestore...');
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      print('📊 Documentos encontrados: ${snapshot.docs.length}');

      List<UserModel> doctors = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              print('📄 Datos del doctor: $data');
              return UserModel.fromMap(data);
            } catch (e) {
              print('⚠️ Error al parsear doctor: $e');
              return null;
            }
          })
          .whereType<UserModel>()
          .toList();

      print('✅ Doctores válidos parseados: ${doctors.length}');

      // Si no hay doctores en Firestore, retornar doctores por defecto
      if (doctors.isEmpty) {
        print('📝 No hay doctores en Firestore, usando doctores por defecto');
        final defaultDoctors = _getDefaultDoctors();
        print('📋 Doctores por defecto: ${defaultDoctors.length}');
        return defaultDoctors;
      }

      return doctors;
    } catch (e) {
      print('❌ Error al obtener doctores: $e');
      // En caso de error, retornar doctores por defecto
      final defaultDoctors = _getDefaultDoctors();
      print('📋 Usando doctores por defecto: ${defaultDoctors.length}');
      return defaultDoctors;
    }
  }

  // Obtener doctores por especialidad
  Future<List<UserModel>> getDoctorsBySpecialty(String specialty) async {
    try {
      print('🔍 Buscando doctores por especialidad ID: $specialty');

      // Convertir ID de especialidad a nombre
      final specialtyName = _getSpecialtyNameById(specialty);
      print('🏥 Nombre de especialidad: $specialtyName');

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('specialty', isEqualTo: specialtyName)
          .get();

      print(
        '📊 Documentos encontrados para $specialtyName: ${snapshot.docs.length}',
      );

      List<UserModel> doctors = snapshot.docs
          .map((doc) {
            try {
              return UserModel.fromMap(doc.data() as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ Error al parsear doctor: $e');
              return null;
            }
          })
          .whereType<UserModel>()
          .toList();

      print('✅ Doctores válidos parseados: ${doctors.length}');

      // Si no hay doctores, filtrar de los doctores por defecto
      if (doctors.isEmpty) {
        print(
          '📝 No hay doctores en Firestore para $specialtyName, usando doctores por defecto',
        );
        final defaultDoctors = _getDefaultDoctors()
            .where((doctor) => doctor.specialty == specialtyName)
            .toList();
        print('📋 Doctores por defecto filtrados: ${defaultDoctors.length}');
        return defaultDoctors;
      }

      return doctors;
    } catch (e) {
      print('❌ Error al obtener doctores por especialidad: $e');
      // En caso de error, filtrar de los doctores por defecto
      final specialtyName = _getSpecialtyNameById(specialty);
      final defaultDoctors = _getDefaultDoctors()
          .where((doctor) => doctor.specialty == specialtyName)
          .toList();
      print('📋 Usando doctores por defecto: ${defaultDoctors.length}');
      return defaultDoctors;
    }
  }

  // Convertir ID de especialidad a nombre
  String _getSpecialtyNameById(String specialtyId) {
    final specialtyMap = {
      '1': 'Medicina General',
      '2': 'Cardiología',
      '3': 'Dermatología',
      '4': 'Pediatría',
      '5': 'Ginecología',
      '6': 'Ortopedia',
      '7': 'Neurología',
      '8': 'Oftalmología',
    };
    return specialtyMap[specialtyId] ?? 'Medicina General';
  }

  // Obtener doctores por defecto
  List<UserModel> _getDefaultDoctors() {
    return [
      UserModel(
        uid: 'default_general',
        email: 'general@loginspace.com',
        name: 'Dr. Roberto Sánchez',
        phone: '+1 234 567 8899',
        role: 'doctor',
        specialty: 'Medicina General',
        licenseNumber: 'LIC123455',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_cardiologia',
        email: 'cardiologia@loginspace.com',
        name: 'Dr. Juan Pérez',
        phone: '+1 234 567 8900',
        role: 'doctor',
        specialty: 'Cardiología',
        licenseNumber: 'LIC123456',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_dermatologia',
        email: 'dermatologia@loginspace.com',
        name: 'Dra. María González',
        phone: '+1 234 567 8901',
        role: 'doctor',
        specialty: 'Dermatología',
        licenseNumber: 'LIC123457',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_pediatria',
        email: 'pediatria@loginspace.com',
        name: 'Dr. Carlos Rodríguez',
        phone: '+1 234 567 8902',
        role: 'doctor',
        specialty: 'Pediatría',
        licenseNumber: 'LIC123458',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_ginecologia',
        email: 'ginecologia@loginspace.com',
        name: 'Dra. Ana Martínez',
        phone: '+1 234 567 8903',
        role: 'doctor',
        specialty: 'Ginecología',
        licenseNumber: 'LIC123459',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_ortopedia',
        email: 'ortopedia@loginspace.com',
        name: 'Dr. Luis Sánchez',
        phone: '+1 234 567 8904',
        role: 'doctor',
        specialty: 'Ortopedia',
        licenseNumber: 'LIC123460',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_neurologia',
        email: 'neurologia@loginspace.com',
        name: 'Dra. Laura Torres',
        phone: '+1 234 567 8905',
        role: 'doctor',
        specialty: 'Neurología',
        licenseNumber: 'LIC123461',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'default_oftalmologia',
        email: 'oftalmologia@loginspace.com',
        name: 'Dr. Pedro Díaz',
        phone: '+1 234 567 8906',
        role: 'doctor',
        specialty: 'Oftalmología',
        licenseNumber: 'LIC123462',
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw 'Error al actualizar perfil: $e';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  // Crear perfiles de doctores por defecto en Firestore
  Future<void> createDefaultDoctors() async {
    try {
      // Verificar si ya existen doctores
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get();

      // Si ya existen doctores, no crear duplicados
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      // Lista de doctores por defecto
      List<Map<String, dynamic>> defaultDoctors = [
        {
          'uid': 'doctor_cardiologia_001',
          'email': 'cardiologia@loginspace.com',
          'name': 'Dr. Juan Pérez',
          'phone': '+1 234 567 8900',
          'role': 'doctor',
          'specialty': 'Cardiología',
          'licenseNumber': 'LIC-CARD-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
        {
          'uid': 'doctor_dermatologia_001',
          'email': 'dermatologia@loginspace.com',
          'name': 'Dra. María González',
          'phone': '+1 234 567 8901',
          'role': 'doctor',
          'specialty': 'Dermatología',
          'licenseNumber': 'LIC-DERM-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
        {
          'uid': 'doctor_pediatria_001',
          'email': 'pediatria@loginspace.com',
          'name': 'Dr. Carlos Rodríguez',
          'phone': '+1 234 567 8902',
          'role': 'doctor',
          'specialty': 'Pediatría',
          'licenseNumber': 'LIC-PED-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
        {
          'uid': 'doctor_ginecologia_001',
          'email': 'ginecologia@loginspace.com',
          'name': 'Dra. Ana Martínez',
          'phone': '+1 234 567 8903',
          'role': 'doctor',
          'specialty': 'Ginecología',
          'licenseNumber': 'LIC-GIN-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
        {
          'uid': 'doctor_ortopedia_001',
          'email': 'ortopedia@loginspace.com',
          'name': 'Dr. Luis Sánchez',
          'phone': '+1 234 567 8904',
          'role': 'doctor',
          'specialty': 'Ortopedia',
          'licenseNumber': 'LIC-ORTO-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
        {
          'uid': 'doctor_neurologia_001',
          'email': 'neurologia@loginspace.com',
          'name': 'Dra. Laura Torres',
          'phone': '+1 234 567 8905',
          'role': 'doctor',
          'specialty': 'Neurología',
          'licenseNumber': 'LIC-NEUR-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
        {
          'uid': 'doctor_oftalmologia_001',
          'email': 'oftalmologia@loginspace.com',
          'name': 'Dr. Pedro Díaz',
          'phone': '+1 234 567 8906',
          'role': 'doctor',
          'specialty': 'Oftalmología',
          'licenseNumber': 'LIC-OFT-001',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      ];

      // Crear cada doctor en Firestore
      for (var doctor in defaultDoctors) {
        await _firestore.collection('users').doc(doctor['uid']).set(doctor);
      }

      print('✅ Doctores por defecto creados exitosamente');
    } catch (e) {
      print('⚠️ Error al crear doctores por defecto: $e');
      // No lanzar error, solo registrar en consola
    }
  }

  // Manejar excepciones de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      case 'invalid-credential':
        return 'Las credenciales son inválidas.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
