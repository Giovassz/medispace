import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/specialty_model.dart';
import 'book_appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  final List<SpecialtyModel> _specialties = SpecialtyModel.getDefaultSpecialties();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo personalizado
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Contenido según el rol
              if (_currentUser!.role == 'patient') ...[
                _buildPatientContent(),
              ] else ...[
                _buildDoctorContent(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, ${_currentUser!.name}!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUser!.role == 'doctor' 
                ? 'Gestiona tus citas médicas'
                : '¿Cómo podemos ayudarte hoy?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botón para agendar cita
        _buildServiceCard(
          title: 'Agendar Cita',
          subtitle: 'Reserva tu cita médica',
          icon: Icons.add_circle_outline,
          color: const Color(0xFF667EEA),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookAppointmentScreen(),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Widget de consejos médicos
        _buildServiceCard(
          title: 'Consejos Médicos',
          subtitle: 'Consejos para aliviar dolores leves',
          icon: Icons.healing_outlined,
          color: const Color(0xFF48BB78),
          onTap: () {
            _showMedicalTipsDialog();
          },
        ),
        
        const SizedBox(height: 16),
        
        // Especialidades médicas
        Text(
          'Especialidades',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _specialties.length,
          itemBuilder: (context, index) {
            final specialty = _specialties[index];
            return _buildSpecialtyCard(specialty);
          },
        ),
      ],
    );
  }

  Widget _buildDoctorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panel de Doctor',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Estadísticas rápidas
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Citas Hoy',
                value: '0',
                icon: Icons.today,
                color: const Color(0xFF667EEA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Citas Pendientes',
                value: '0',
                icon: Icons.pending,
                color: const Color(0xFFF6AD55),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Acciones rápidas
        _buildServiceCard(
          title: 'Ver Mis Citas',
          subtitle: 'Gestiona tu agenda',
          icon: Icons.event_note,
          color: const Color(0xFF48BB78),
          onTap: () {
            // Navegar a la pantalla de citas del doctor
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF718096),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookAppointmentScreen(selectedSpecialty: specialty.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSpecialtyIcon(specialty.icon),
              size: 32,
              color: const Color(0xFF667EEA),
            ),
            const SizedBox(height: 8),
            Text(
              specialty.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicalTipsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.healing,
                color: const Color(0xFF48BB78),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Consejos Médicos',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTipCard(
                  'Dolor de Cabeza',
                  '• Aplica compresas frías en la frente\n• Bebe agua suficiente\n• Descansa en un ambiente oscuro\n• Evita el estrés y la cafeína',
                  Icons.psychology,
                ),
                _buildTipCard(
                  'Dolor de Garganta',
                  '• Haz gárgaras con agua salada tibia\n• Bebe líquidos calientes\n• Usa un humidificador\n• Evita fumar y el aire seco',
                  Icons.healing,
                ),
                _buildTipCard(
                  'Dolor Muscular',
                  '• Aplica hielo por 15-20 minutos\n• Estira suavemente el músculo\n• Toma un baño caliente\n• Masajea el área afectada',
                  Icons.fitness_center,
                ),
                _buildTipCard(
                  'Malestar Estomacal',
                  '• Bebe té de manzanilla\n• Evita alimentos grasos\n• Come porciones pequeñas\n• Mantén una dieta blanda',
                  Icons.restaurant,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: const Color(0xFFE53E3E),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Si los síntomas persisten o empeoran, consulta a un médico inmediatamente.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFFE53E3E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF48BB78),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF4A5568),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSpecialtyIcon(String iconName) {
    switch (iconName) {
      case 'medical_services':
        return Icons.medical_services;
      case 'favorite':
        return Icons.favorite;
      case 'face':
        return Icons.face;
      case 'child_care':
        return Icons.child_care;
      case 'pregnant_woman':
        return Icons.pregnant_woman;
      case 'accessibility':
        return Icons.accessibility;
      case 'psychology':
        return Icons.psychology;
      case 'visibility':
        return Icons.visibility;
      default:
        return Icons.medical_services;
    }
  }
}