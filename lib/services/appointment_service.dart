import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una nueva cita
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('appointments')
          .add(appointment.toMap());

      // Actualizar el ID del appointment
      await _firestore.collection('appointments').doc(docRef.id).update({
        'id': docRef.id,
      });

      return docRef.id;
    } catch (e) {
      throw 'Error al crear cita: $e';
    }
  }

  // Obtener citas de un paciente
  Future<List<AppointmentModel>> getPatientAppointments(
    String patientId,
  ) async {
    try {
      // Obtener todas las citas del paciente sin ordenar
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();

      // Convertir a lista de AppointmentModel
      List<AppointmentModel> appointments = snapshot.docs
          .map(
            (doc) =>
                AppointmentModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Ordenar por fecha en el cliente
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return appointments;
    } catch (e) {
      print('❌ Error al obtener citas del paciente: $e');
      return []; // Retornar lista vacía en caso de error
    }
  }

  // Obtener citas de un doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      // Obtener todas las citas del doctor sin ordenar
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      // Convertir a lista de AppointmentModel
      List<AppointmentModel> appointments = snapshot.docs
          .map(
            (doc) =>
                AppointmentModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Ordenar por fecha en el cliente
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return appointments;
    } catch (e) {
      print('❌ Error al obtener citas del doctor: $e');
      return []; // Retornar lista vacía en caso de error
    }
  }

  // Actualizar estado de una cita
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error al actualizar estado de la cita: $e';
    }
  }

  // Actualizar cita completa
  Future<void> updateAppointment(
    String appointmentId,
    AppointmentModel updatedAppointment,
  ) async {
    try {
      // Verificar disponibilidad si se cambió la fecha/hora
      final isAvailable = await isTimeSlotAvailable(
        updatedAppointment.doctorId,
        updatedAppointment.dateTime,
      );

      if (!isAvailable) {
        throw 'Este horario no está disponible';
      }

      await _firestore.collection('appointments').doc(appointmentId).update({
        'doctorId': updatedAppointment.doctorId,
        'doctorName': updatedAppointment.doctorName,
        'doctorSpecialty': updatedAppointment.doctorSpecialty,
        'dateTime': Timestamp.fromDate(updatedAppointment.dateTime),
        'reason': updatedAppointment.reason,
        'notes': updatedAppointment.notes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error al actualizar cita: $e';
    }
  }

  // Eliminar cita con confirmación
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw 'Error al eliminar cita: $e';
    }
  }

  // Cancelar una cita
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error al cancelar cita: $e';
    }
  }

  // Obtener citas por fecha
  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('dateTime')
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                AppointmentModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw 'Error al obtener citas por fecha: $e';
    }
  }

  // Verificar disponibilidad de horario
  Future<bool> isTimeSlotAvailable(String doctorId, DateTime dateTime) async {
    try {
      // Obtener todas las citas del doctor y filtrar en el cliente
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .get();

      // Filtrar por fecha y hora en el cliente
      DateTime startTime = dateTime.subtract(const Duration(minutes: 30));
      DateTime endTime = dateTime.add(const Duration(minutes: 30));

      bool hasConflict = snapshot.docs.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final appointmentTime = (data['dateTime'] as Timestamp).toDate();

        // Verificar si hay conflicto de horario (incluye los límites)
        return appointmentTime.isAfter(
              startTime.subtract(const Duration(milliseconds: 1)),
            ) &&
            appointmentTime.isBefore(
              endTime.add(const Duration(milliseconds: 1)),
            );
      });

      return !hasConflict;
    } catch (e) {
      // Si hay error, asumir que está disponible
      print('⚠️ Error al verificar disponibilidad: $e');
      return true;
    }
  }

  // Crear citas de ejemplo
  Future<void> createSampleAppointments() async {
    try {
      // Verificar si ya existen citas
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .limit(1)
          .get();

      // Si ya existen citas, no crear duplicados
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      DateTime now = DateTime.now();

      // Lista de citas de ejemplo
      List<Map<String, dynamic>> sampleAppointments = [
        {
          'id': 'appt_001',
          'patientId': 'sample_patient_001',
          'patientName': 'María García',
          'patientPhone': '+1 234 567 8001',
          'doctorId': 'doctor_cardiologia_001',
          'doctorName': 'Dr. Juan Pérez',
          'doctorSpecialty': 'Cardiología',
          'dateTime': Timestamp.fromDate(now.add(const Duration(days: 2))),
          'status': 'scheduled',
          'reason': 'Consulta de rutina',
          'notes': 'Primera consulta',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        },
        {
          'id': 'appt_002',
          'patientId': 'sample_patient_002',
          'patientName': 'Carlos López',
          'patientPhone': '+1 234 567 8002',
          'doctorId': 'doctor_pediatria_001',
          'doctorName': 'Dr. Carlos Rodríguez',
          'doctorSpecialty': 'Pediatría',
          'dateTime': Timestamp.fromDate(now.add(const Duration(days: 3))),
          'status': 'confirmed',
          'reason': 'Vacunación',
          'notes': 'Vacuna anual',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        },
        {
          'id': 'appt_003',
          'patientId': 'sample_patient_003',
          'patientName': 'Ana Martínez',
          'patientPhone': '+1 234 567 8003',
          'doctorId': 'doctor_dermatologia_001',
          'doctorName': 'Dra. María González',
          'doctorSpecialty': 'Dermatología',
          'dateTime': Timestamp.fromDate(now.add(const Duration(days: 5))),
          'status': 'scheduled',
          'reason': 'Revisión de lunares',
          'notes': 'Examen de piel',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        },
        {
          'id': 'appt_004',
          'patientId': 'sample_patient_001',
          'patientName': 'María García',
          'patientPhone': '+1 234 567 8001',
          'doctorId': 'doctor_oftalmologia_001',
          'doctorName': 'Dr. Pedro Díaz',
          'doctorSpecialty': 'Oftalmología',
          'dateTime': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
          'status': 'completed',
          'reason': 'Examen de la vista',
          'notes': 'Consulta completada',
          'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 10)),
          ),
          'updatedAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 7)),
          ),
        },
        {
          'id': 'appt_005',
          'patientId': 'sample_patient_004',
          'patientName': 'Juan Hernández',
          'patientPhone': '+1 234 567 8004',
          'doctorId': 'doctor_ortopedia_001',
          'doctorName': 'Dr. Luis Sánchez',
          'doctorSpecialty': 'Ortopedia',
          'dateTime': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
          'status': 'cancelled',
          'reason': 'Dolor en rodilla',
          'notes': 'Cita cancelada por el paciente',
          'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 5)),
          ),
          'updatedAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 3)),
          ),
        },
      ];

      // Crear cada cita en Firestore
      for (var appointment in sampleAppointments) {
        await _firestore
            .collection('appointments')
            .doc(appointment['id'])
            .set(appointment);
      }

      print('✅ Citas de ejemplo creadas exitosamente');
    } catch (e) {
      print('⚠️ Error al crear citas de ejemplo: $e');
      // No lanzar error, solo registrar en consola
    }
  }
}
