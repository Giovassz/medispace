part of 'dashboard_bloc.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalAppointments;
  final int pendingAppointments;
  final int totalPatients;
  
  DashboardLoaded({
    required this.totalAppointments,
    required this.pendingAppointments,
    required this.totalPatients,
  });
}

class DashboardError extends DashboardState {
  final String message;
  
  DashboardError(this.message);
}

