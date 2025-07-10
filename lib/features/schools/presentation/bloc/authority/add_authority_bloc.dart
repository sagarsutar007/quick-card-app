import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcard/features/schools/domain/repositories/school_repository.dart';
import 'package:quickcard/features/schools/presentation/bloc/authority/add_authority_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/authority/add_authority_state.dart';

class AddAuthorityBloc extends Bloc<AddAuthorityEvent, AddAuthorityState> {
  final SchoolRepository repository;

  AddAuthorityBloc(this.repository) : super(AddAuthorityInitial()) {
    on<SubmitAuthorityEvent>((event, emit) async {
      emit(AddAuthorityLoading());
      try {
        await repository.addAuthority(event.schoolId, event.model);
        emit(AddAuthoritySuccess());
      } catch (e) {
        emit(AddAuthorityFailure(e.toString()));
      }
    });
  }
}
