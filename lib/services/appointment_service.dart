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
      await _firestore
          .collection('appointments')
          .doc(docRef.id)
          .update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw 'Error al crear cita: $e';
    }
  }

  // Obtener citas de un paciente
  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('dateTime', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener citas del paciente: $e';
    }
  }

  // Obtener citas de un doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('dateTime', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener citas del doctor: $e';
    }
  }

  // Actualizar estado de una cita
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
            'status': status,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw 'Error al actualizar estado de la cita: $e';
    }
  }

  // Actualizar cita completa
  Future<void> updateAppointment(String appointmentId, AppointmentModel updatedAppointment) async {
    try {
      // Verificar disponibilidad si se cambió la fecha/hora
      final isAvailable = await isTimeSlotAvailable(
        updatedAppointment.doctorId,
        updatedAppointment.dateTime,
      );

      if (!isAvailable) {
        throw 'Este horario no está disponible';
      }

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
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
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw 'Error al eliminar cita: $e';
    }
  }

  // Cancelar una cita
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
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
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('dateTime')
          .get();
      
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener citas por fecha: $e';
    }
  }

  // Verificar disponibilidad de horario
  Future<bool> isTimeSlotAvailable(String doctorId, DateTime dateTime) async {
    try {
      DateTime startTime = dateTime.subtract(const Duration(minutes: 30));
      DateTime endTime = dateTime.add(const Duration(minutes: 30));
      
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .get();
      
      return snapshot.docs.isEmpty;
    } catch (e) {
      throw 'Error al verificar disponibilidad: $e';
    }
  }
}
