import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _appointmentsSubscription;

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    
    // Cancelar suscripción anterior si existe
    await _appointmentsSubscription?.cancel();
    
    try {
      // Suscribirse a cambios en tiempo real de las citas del doctor
      _appointmentsSubscription = _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: event.doctorId)
          .snapshots()
          .listen(
        (snapshot) {
          // Calcular estadísticas desde los documentos
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromMap(
                    doc.data(),
                  ))
              .toList();
          
          // Calcular estadísticas
          final totalAppointments = appointments.length;
          
          // Citas pendientes: scheduled o confirmed que aún no han pasado
          final now = DateTime.now();
          final pendingAppointments = appointments.where((appointment) {
            final isPending = appointment.status == 'scheduled' || 
                            appointment.status == 'confirmed';
            final isFuture = appointment.dateTime.isAfter(now);
            return isPending && isFuture;
          }).length;
          
          // Total de pacientes únicos
          final uniquePatientIds = appointments.map((a) => a.patientId).toSet();
          final totalPatients = uniquePatientIds.length;
          
          emit(DashboardLoaded(
            totalAppointments: totalAppointments,
            pendingAppointments: pendingAppointments,
            totalPatients: totalPatients,
          ));
        },
        onError: (error) {
          emit(DashboardError('Error al cargar datos: $error'));
        },
      );
    } catch (e) {
      emit(DashboardError('Error al cargar datos: $e'));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Recargar datos
    add(LoadDashboardData(event.doctorId));
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}

