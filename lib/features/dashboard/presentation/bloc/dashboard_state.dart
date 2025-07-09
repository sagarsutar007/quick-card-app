import '../../data/models/dashboard_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel dashboard;

  DashboardLoaded(this.dashboard);
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
