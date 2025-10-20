import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<MessageModel> _messages = [
    MessageModel(
      id: '1',
      senderName: 'Dr. María González',
      senderSpecialty: 'Cardiología',
      lastMessage: 'Hola, ¿cómo te sientes después de la consulta?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      senderAvatar: 'MG',
    ),
    MessageModel(
      id: '2',
      senderName: 'Dr. Carlos Ruiz',
      senderSpecialty: 'Dermatología',
      lastMessage: 'Los resultados de tus exámenes están listos',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      senderAvatar: 'CR',
    ),
    MessageModel(
      id: '3',
      senderName: 'Dr. Ana Martínez',
      senderSpecialty: 'Pediatría',
      lastMessage: 'Recuerda tomar la medicación con las comidas',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      senderAvatar: 'AM',
    ),
    MessageModel(
      id: '4',
      senderName: 'Dr. Luis Herrera',
      senderSpecialty: 'Ortopedia',
      lastMessage: '¿Cómo va la recuperación de tu lesión?',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      senderAvatar: 'LH',
    ),
    MessageModel(
      id: '5',
      senderName: 'Dr. Patricia López',
      senderSpecialty: 'Ginecología',
      lastMessage: 'Tu próxima cita está programada para el viernes',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
      senderAvatar: 'PL',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Mensajes',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF667EEA),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de mensajes
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes mensajes',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los mensajes de tus doctores aparecerán aquí',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageCard(message);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(MessageModel message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                message.senderAvatar,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667EEA),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Contenido del mensaje
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        message.senderName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    if (!message.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF667EEA),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  message.senderSpecialty,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  message.lastMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF2D3748),
                    fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _formatTimestamp(message.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          
          // Icono de flecha
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF718096),
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}

class MessageModel {
  final String id;
  final String senderName;
  final String senderSpecialty;
  final String lastMessage;
  final DateTime timestamp;
  final bool isRead;
  final String senderAvatar;

  MessageModel({
    required this.id,
    required this.senderName,
    required this.senderSpecialty,
    required this.lastMessage,
    required this.timestamp,
    required this.isRead,
    required this.senderAvatar,
  });
}
