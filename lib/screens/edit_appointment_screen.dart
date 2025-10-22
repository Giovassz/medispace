import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/appointment_service.dart';
import '../models/user_model.dart';
import '../models/specialty_model.dart';
import '../models/appointment_model.dart';

class EditAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;
  
  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
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
    _initializeData();
  }

  void _initializeData() {
    _selectedSpecialty = widget.appointment.doctorSpecialty;
    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);
    _reasonController.text = widget.appointment.reason ?? '';
    _notesController.text = widget.appointment.notes ?? '';
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      List<UserModel> doctors;
      if (_selectedSpecialty != null) {
        doctors = await _authService.getDoctorsBySpecialty(_selectedSpecialty!);
      } else {
        doctors = await _authService.getDoctors();
      }
      
      // Encontrar el doctor actual
      _selectedDoctor = doctors.firstWhere(
        (doctor) => doctor.uid == widget.appointment.doctorId,
        orElse: () => doctors.isNotEmpty ? doctors.first : UserModel(
          uid: '',
          email: '',
          name: '',
          phone: '',
          role: '',
          createdAt: DateTime.now(),
        ),
      );
      
      setState(() {
        _doctors = doctors;
      });
    } catch (e) {
      _showErrorSnackBar('Error al cargar doctores: $e');
    }
  }

  Future<void> _updateAppointment() async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) {
      _showErrorSnackBar('Por favor completa todos los campos requeridos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final updatedAppointment = widget.appointment.copyWith(
        doctorId: _selectedDoctor!.uid,
        doctorName: _selectedDoctor!.name,
        doctorSpecialty: _selectedDoctor!.specialty ?? '',
        dateTime: appointmentDateTime,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _appointmentService.updateAppointment(widget.appointment.id, updatedAppointment);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita actualizada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar('Error al actualizar cita: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmar eliminación',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta cita? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _appointmentService.deleteAppointment(widget.appointment.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        _showErrorSnackBar('Error al eliminar cita: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
          'Editar Cita',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteAppointment,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información actual de la cita
            _buildCurrentInfoCard(),
            
            const SizedBox(height: 24),
            
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
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Actualizar Cita',
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
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información actual de la cita',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Doctor: Dr. ${widget.appointment.doctorName}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.appointment.dateTime)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
          Text(
            'Estado: ${widget.appointment.status}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
        ],
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
          initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
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
          initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
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
