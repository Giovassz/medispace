part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final String doctorId;
  
  LoadDashboardData(this.doctorId);
}

class RefreshDashboardData extends DashboardEvent {
  final String doctorId;
  
  RefreshDashboardData(this.doctorId);
}

