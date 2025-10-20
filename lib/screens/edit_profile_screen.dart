import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _medicalConditionsController;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
    _birthPlaceController = TextEditingController();
    _medicalConditionsController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUserData();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _phoneController.text = user.phone;
          _ageController.text = user.age?.toString() ?? '';
          _birthPlaceController.text = user.birthPlace ?? '';
          _medicalConditionsController.text = user.medicalConditions ?? '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar datos del usuario: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        if (_currentUser != null) {
          final updatedUser = _currentUser!.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            age: int.tryParse(_ageController.text.trim()),
            birthPlace: _birthPlaceController.text.trim().isEmpty 
                ? null 
                : _birthPlaceController.text.trim(),
            medicalConditions: _medicalConditionsController.text.trim().isEmpty 
                ? null 
                : _medicalConditionsController.text.trim(),
          );

          await _authService.updateUserProfile(updatedUser);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        _showErrorSnackBar('Error al actualizar perfil: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _birthPlaceController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información personal
              _buildSectionTitle('Información Personal'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _nameController,
                label: 'Nombre completo',
                hint: 'Ingresa tu nombre completo',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Teléfono',
                hint: 'Ingresa tu número de teléfono',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu teléfono';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _ageController,
                label: 'Edad',
                hint: 'Ingresa tu edad',
                prefixIcon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final age = int.tryParse(value.trim());
                    if (age == null || age < 0 || age > 150) {
                      return 'Por favor ingresa una edad válida';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _birthPlaceController,
                label: 'Lugar de nacimiento',
                hint: 'Ingresa tu lugar de nacimiento',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) {
                  // Este campo es opcional, no necesita validación
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Información médica
              _buildSectionTitle('Información Médica'),
              const SizedBox(height: 16),
              
              TextField(
                controller: _medicalConditionsController,
                decoration: InputDecoration(
                  labelText: 'Padecimientos médicos',
                  hintText: 'Describe cualquier padecimiento o condición médica',
                  prefixIcon: const Icon(Icons.medical_services_outlined),
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
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              
              const SizedBox(height: 32),
              
              // Botón de guardar
              CustomButton(
                text: 'Guardar Cambios',
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D3748),
      ),
    );
  }
}
