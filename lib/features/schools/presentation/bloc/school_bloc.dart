import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcard/features/schools/presentation/bloc/school_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/school_state.dart';
import 'package:quickcard/features/schools/domain/repositories/school_repository.dart';

class SchoolBloc extends Bloc<SchoolEvent, SchoolState> {
  final SchoolRepository repository;

  SchoolBloc(this.repository) : super(SchoolInitial()) {
    on<LoadSchools>((event, emit) async {
      emit(SchoolLoading());
      try {
        final schools = await repository.getSchools();
        emit(SchoolLoaded(schools));
      } catch (e) {
        emit(SchoolError(e.toString()));
      }
    });

    on<SearchSchools>((event, emit) async {
      emit(SchoolLoading());
      try {
        final schools = await repository.searchSchools(event.query);
        emit(SchoolLoaded(schools));
      } catch (e) {
        emit(SchoolError(e.toString()));
      }
    });
  }
}
