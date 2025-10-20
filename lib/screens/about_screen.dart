import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Sobre Nosotros',
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
            // Header con logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      size: 40,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'MediSpace',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Tu espacio médico de confianza',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Versión 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Misión
            _buildInfoSection(
              'Nuestra Misión',
              'Conectar a pacientes con profesionales médicos de manera eficiente, segura y accesible. Creemos que la atención médica de calidad debe estar al alcance de todos, sin importar las barreras geográficas o de tiempo.',
              Icons.flag,
            ),
            
            // Visión
            _buildInfoSection(
              'Nuestra Visión',
              'Ser la plataforma líder en gestión de citas médicas, revolucionando la forma en que las personas acceden a servicios de salud, promoviendo la prevención y el bienestar integral.',
              Icons.visibility,
            ),
            
            // Valores
            _buildInfoSection(
              'Nuestros Valores',
              '• Confianza: Protegemos tu información con los más altos estándares de seguridad\n• Accesibilidad: Servicios disponibles 24/7 desde cualquier lugar\n• Calidad: Conectamos solo con profesionales médicos certificados\n• Innovación: Utilizamos tecnología de vanguardia para mejorar tu experiencia\n• Compromiso: Tu salud y bienestar son nuestra prioridad',
              Icons.favorite,
            ),
            
            // Características
            _buildInfoSection(
              'Características Principales',
              '• Agendamiento de citas en tiempo real\n• Recordatorios automáticos\n• Historial médico digital\n• Comunicación directa con doctores\n• Múltiples especialidades médicas\n• Interfaz intuitiva y fácil de usar\n• Seguridad y privacidad garantizadas',
              Icons.star,
            ),
            
            // Equipo
            _buildInfoSection(
              'Nuestro Equipo',
              'MediSpace está desarrollado por un equipo multidisciplinario de profesionales en tecnología, medicina y experiencia de usuario, comprometidos con la innovación en el sector salud.',
              Icons.people,
            ),
            
            // Contacto
            _buildInfoSection(
              'Contacto',
              '¿Tienes preguntas o sugerencias?\n\n• Email: contacto@medispace.com\n• Teléfono: +1 (555) 123-4567\n• Soporte: soporte@medispace.com\n• Dirección: 123 Medical Innovation St, Tech City\n\nHorario de atención: Lunes a Viernes, 8:00 AM - 6:00 PM',
              Icons.contact_mail,
            ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Aquí podrías implementar compartir la app
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de compartir próximamente disponible'),
                          backgroundColor: Color(0xFF667EEA),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: Text(
                      'Compartir',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48BB78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Aquí podrías implementar calificar la app
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de calificación próximamente disponible'),
                          backgroundColor: Color(0xFF667EEA),
                        ),
                      );
                    },
                    icon: const Icon(Icons.star, color: Colors.white),
                    label: Text(
                      'Calificar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6AD55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Copyright
            Center(
              child: Text(
                '© 2024 MediSpace. Todos los derechos reservados.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF4A5568),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
