import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<LoadDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        final dashboard = await repository.fetchDashboard();
        emit(DashboardLoaded(dashboard));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });
  }
}
