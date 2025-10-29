import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/appointment_service.dart';
import '../models/user_model.dart';
import '../models/specialty_model.dart';
import '../models/appointment_model.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String? selectedSpecialty;
  
  const BookAppointmentScreen({super.key, this.selectedSpecialty});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  
  List<UserModel> _doctors = [];
  final List<SpecialtyModel> _specialties = SpecialtyModel.getDefaultSpecialties();
  UserModel? _selectedDoctor;
  String? _selectedSpecialty;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = widget.selectedSpecialty;
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      List<UserModel> doctors;
      if (_selectedSpecialty != null) {
        doctors = await _authService.getDoctorsBySpecialty(_selectedSpecialty!);
      } else {
        doctors = await _authService.getDoctors();
      }
      
      // Debug: imprimir información
      print('📋 Total de doctores cargados: ${doctors.length}');
      if (_selectedSpecialty != null) {
        print('🔍 Especialidad filtrada: $_selectedSpecialty');
      }
      for (var doctor in doctors) {
        print('👨‍⚕️ Doctor: ${doctor.name} - ${doctor.specialty}');
      }
      
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error al cargar doctores: $e');
      setState(() {
        _isLoading = false;
        _doctors = []; // Asegurar que la lista esté vacía en caso de error
      });
      if (mounted) {
        _showErrorSnackBar('Error al cargar doctores: $e');
      }
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) {
      _showErrorSnackBar('Por favor completa todos los campos requeridos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _authService.getCurrentUserData();
      if (currentUser == null) {
        _showErrorSnackBar('Usuario no encontrado');
        return;
      }

      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Verificar disponibilidad
      final isAvailable = await _appointmentService.isTimeSlotAvailable(
        _selectedDoctor!.uid,
        appointmentDateTime,
      );

      if (!isAvailable) {
        _showErrorSnackBar('Este horario no está disponible');
        return;
      }

      final appointment = AppointmentModel(
        id: '', // Se asignará automáticamente
        patientId: currentUser.uid,
        patientName: currentUser.name,
        patientPhone: currentUser.phone,
        doctorId: _selectedDoctor!.uid,
        doctorName: _selectedDoctor!.name,
        doctorSpecialty: _selectedDoctor!.specialty ?? '',
        dateTime: appointmentDateTime,
        status: 'scheduled',
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _appointmentService.createAppointment(appointment);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita agendada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Error al agendar cita: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Agendar Cita',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de especialidad
            _buildSectionTitle('Especialidad'),
            const SizedBox(height: 12),
            _buildSpecialtyDropdown(),
            
            const SizedBox(height: 24),
            
            // Selección de doctor
            _buildSectionTitle('Doctor'),
            const SizedBox(height: 12),
            _buildDoctorDropdown(),
            
            const SizedBox(height: 24),
            
            // Selección de fecha
            _buildSectionTitle('Fecha'),
            const SizedBox(height: 12),
            _buildDateSelector(),
            
            const SizedBox(height: 24),
            
            // Selección de hora
            _buildSectionTitle('Hora'),
            const SizedBox(height: 12),
            _buildTimeSelector(),
            
            const SizedBox(height: 24),
            
            // Motivo de la cita
            _buildSectionTitle('Motivo de la cita (opcional)'),
            const SizedBox(height: 12),
            _buildReasonField(),
            
            const SizedBox(height: 24),
            
            // Notas adicionales
            _buildSectionTitle('Notas adicionales (opcional)'),
            const SizedBox(height: 12),
            _buildNotesField(),
            
            const SizedBox(height: 32),
            
            // Botón para agendar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Agendar Cita',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildSpecialtyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSpecialty,
          hint: Text(
            'Selecciona una especialidad',
            style: GoogleFonts.poppins(
              color: const Color(0xFF718096),
            ),
          ),
          isExpanded: true,
          items: _specialties.map((specialty) {
            return DropdownMenuItem<String>(
              value: specialty.id,
              child: Text(
                specialty.name,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSpecialty = value;
              _selectedDoctor = null;
            });
            _loadDoctors();
          },
        ),
      ),
    );
  }

  Widget _buildDoctorDropdown() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Cargando doctores...',
              style: GoogleFonts.poppins(
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_doctors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'No hay doctores disponibles',
          style: GoogleFonts.poppins(
            color: const Color(0xFF718096),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserModel>(
          value: _selectedDoctor,
          hint: Text(
            'Selecciona un doctor',
            style: GoogleFonts.poppins(
              color: const Color(0xFF718096),
            ),
          ),
          isExpanded: true,
          items: _doctors.map((doctor) {
            return DropdownMenuItem<UserModel>(
              value: doctor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctor.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    doctor.specialty ?? 'Especialidad no especificada',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDoctor = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF718096)),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                  : 'Selecciona una fecha',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _selectedDate != null
                    ? const Color(0xFF2D3748)
                    : const Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF718096)),
            const SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'Selecciona una hora',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _selectedTime != null
                    ? const Color(0xFF2D3748)
                    : const Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      decoration: InputDecoration(
        hintText: 'Describe brevemente el motivo de tu cita',
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF718096),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: InputDecoration(
        hintText: 'Agrega cualquier información adicional',
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF718096),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
