import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Privacidad y Seguridad',
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
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu Privacidad es Importante',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Protegemos tu información médica',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contenido de privacidad
            _buildPrivacySection(
              'Recopilación de Información',
              'Recopilamos únicamente la información necesaria para brindarte el mejor servicio médico:\n\n• Información personal básica (nombre, email, teléfono)\n• Información médica relevante para tu atención\n• Historial de citas y consultas\n• Datos de contacto de emergencia',
            ),
            
            _buildPrivacySection(
              'Uso de la Información',
              'Utilizamos tu información para:\n\n• Programar y gestionar tus citas médicas\n• Proporcionar recordatorios de citas\n• Mejorar nuestros servicios\n• Comunicarnos contigo sobre tu salud\n• Cumplir con obligaciones legales médicas',
            ),
            
            _buildPrivacySection(
              'Protección de Datos',
              'Implementamos medidas de seguridad avanzadas:\n\n• Cifrado de extremo a extremo\n• Acceso restringido a personal autorizado\n• Cumplimiento con normativas de salud (HIPAA)\n• Auditorías regulares de seguridad\n• Respaldo seguro de información',
            ),
            
            _buildPrivacySection(
              'Compartir Información',
              'No vendemos ni compartimos tu información personal con terceros, excepto:\n\n• Con tu consentimiento explícito\n• Con profesionales médicos autorizados\n• Para cumplir con obligaciones legales\n• En casos de emergencia médica',
            ),
            
            _buildPrivacySection(
              'Tus Derechos',
              'Tienes derecho a:\n\n• Acceder a tu información personal\n• Corregir datos inexactos\n• Solicitar la eliminación de datos\n• Obtener una copia de tu información\n• Retirar tu consentimiento en cualquier momento',
            ),
            
            _buildPrivacySection(
              'Contacto',
              'Para preguntas sobre privacidad:\n\n• Email: privacidad@medispace.com\n• Teléfono: +1 (555) 123-4567\n• Dirección: 123 Medical St, Health City\n\nActualizamos esta política regularmente. Te notificaremos sobre cambios importantes.',
            ),
            
            const SizedBox(height: 24),
            
            // Botón de contacto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí podrías implementar un formulario de contacto
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de contacto próximamente disponible'),
                      backgroundColor: Color(0xFF667EEA),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Contactar sobre Privacidad',
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

  Widget _buildPrivacySection(String title, String content) {
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
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
