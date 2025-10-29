import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
import 'services/appointment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crear perfiles de doctores por defecto
  final authService = AuthService();
  await authService.createDefaultDoctors();

  // Crear citas de ejemplo
  final appointmentService = AppointmentService();
  await appointmentService.createSampleAppointments();

  runApp(const MediSpaceApp());
}

class MediSpaceApp extends StatelessWidget {
  const MediSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediSpace - Login Médico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Mostrar loading mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            ),
          );
        }

        // Si el usuario está autenticado, mostrar MainNavigationScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }

        // Si no está autenticado, mostrar LoginScreen
        return const LoginScreen();
      },
    );
  }
}
