import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  
  UserModel? _currentUser;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

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
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (_currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      List<AppointmentModel> appointments;
      if (_currentUser!.role == 'doctor') {
        appointments = await _appointmentService.getDoctorAppointments(_currentUser!.uid);
      } else {
        appointments = await _appointmentService.getPatientAppointments(_currentUser!.uid);
      }
      
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      _showErrorSnackBar('Error al cargar citas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AppointmentModel> _getFilteredAppointments() {
    if (_selectedFilter == 'all') return _appointments;
    return _appointments.where((appointment) => appointment.status == _selectedFilter).toList();
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _appointmentService.updateAppointmentStatus(appointmentId, status);
      _loadAppointments();
      _showSuccessSnackBar('Estado de cita actualizado');
    } catch (e) {
      _showErrorSnackBar('Error al actualizar cita: $e');
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(appointmentId);
      _loadAppointments();
      _showSuccessSnackBar('Cita cancelada');
    } catch (e) {
      _showErrorSnackBar('Error al cancelar cita: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getAppointmentStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFF667EEA);
      case 'confirmed':
        return const Color(0xFF48BB78);
      case 'completed':
        return const Color(0xFF718096);
      case 'cancelled':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF718096);
    }
  }

  String _getAppointmentStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programada';
      case 'confirmed':
        return 'Confirmada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
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

    final filteredAppointments = _getFilteredAppointments();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    _currentUser!.role == 'doctor' ? 'Mis Citas' : 'Mis Citas',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            
            // Filtros
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Todas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('scheduled', 'Programadas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('confirmed', 'Confirmadas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('completed', 'Completadas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('cancelled', 'Canceladas'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Lista de citas
            Expanded(
              child: filteredAppointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay citas disponibles',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF718096),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAppointmentStatusColor(appointment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getAppointmentStatusText(appointment.status),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getAppointmentStatusColor(appointment.status),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
                child: Icon(
                  _currentUser!.role == 'doctor' ? Icons.person : Icons.medical_services,
                  color: const Color(0xFF667EEA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser!.role == 'doctor' 
                          ? appointment.patientName
                          : 'Dr. ${appointment.doctorName}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctorSpecialty,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    if (_currentUser!.role == 'doctor') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tel: ${appointment.patientPhone}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (appointment.reason != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Motivo:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.reason!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (appointment.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notas:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.notes!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Acciones para doctores
          if (_currentUser!.role == 'doctor' && appointment.status != 'cancelled' && appointment.status != 'completed') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (appointment.status == 'scheduled') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateAppointmentStatus(appointment.id, 'confirmed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48BB78),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirmar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (appointment.status == 'confirmed') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateAppointmentStatus(appointment.id, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Completar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelAppointment(appointment.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53E3E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE53E3E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
