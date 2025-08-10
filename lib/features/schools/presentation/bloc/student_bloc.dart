import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';
import 'package:quickcard/features/schools/presentation/bloc/student_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;
  final Set<String> _visitedTabs = {};

  StudentBloc(this.repository) : super(const StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<SearchStudents>(_onSearchStudents);
    on<RefreshStudents>(_onRefreshStudents);
    on<LoadMoreStudents>(_onLoadMoreStudents);
    on<FetchStudents>(_onFilterStudents);
    on<FetchMoreStudents>(_onFetchMoreStudents);
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentState> emit,
  ) async {
    final statusKey = event.status ?? 'all';

    if (_visitedTabs.contains(statusKey)) {
      add(
        RefreshStudents(
          event.schoolId,
          status: event.status,
          studentClass: event.studentClass,
          dob: event.dob,
        ),
      );
      return;
    }

    _visitedTabs.add(statusKey);

    await _fetchStudents(
      emit,
      schoolId: event.schoolId,
      status: event.status,
      query: event.query,
      studentClass: event.studentClass,
      dob: event.dob,
    );
  }

  Future<void> _onSearchStudents(
    SearchStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final response = await repository.fetchStudents(
        event.schoolId,
        queryParams: {
          'q': event.query,
          if (event.status != null) 'status': event.status!,
          if (event.studentClass != null) 'class': event.studentClass!,
          if (event.dob != null) 'dob': event.dob!,
        },
      );

      emit(
        StudentLoaded(
          students: response.students,
          canUploadImage: response.canUploadImage,
          canRemoveImage: response.canRemoveImage,
          currentPage: response.pagination.currentPage,
          hasMore: response.pagination.hasMorePages,
          query: event.query,
          currentStatus: event.status,
          studentClass: event.studentClass,
          dob: event.dob,
          canAddAuthority: response.canAddAuthority,
        ),
      );
    } catch (e, stackTrace) {
      emit(StudentError('Search failed: ${e.toString()}'));
      addError(e, stackTrace);
    }
  }

  Future<void> _onFilterStudents(
    FetchStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final response = await repository.filterStudents(
        queryParams: {
          'q': event.query,
          if (event.status != null) 'status': event.status!,
          if (event.studentClass != null) 'class': event.studentClass!,
          if (event.dob != null) 'dob': event.dob!,
        },
      );

      emit(
        StudentLoaded(
          students: response.students,
          canUploadImage: response.canUploadImage,
          canRemoveImage: response.canRemoveImage,
          currentPage: response.pagination.currentPage,
          hasMore: response.pagination.hasMorePages,
          query: event.query,
          currentStatus: event.status,
          studentClass: event.studentClass,
          dob: event.dob,
          canAddAuthority: response.canAddAuthority,
        ),
      );
    } catch (e, stackTrace) {
      emit(StudentError('Search failed: ${e.toString()}'));
      addError(e, stackTrace);
    }
  }

  Future<void> _onRefreshStudents(
    RefreshStudents event,
    Emitter<StudentState> emit,
  ) async {
    await _fetchStudents(
      emit,
      schoolId: event.schoolId,
      status: event.status,
      studentClass: event.studentClass,
      dob: event.dob,
    );
  }

  Future<void> _fetchStudents(
    Emitter<StudentState> emit, {
    required int schoolId,
    String? status,
    String? query,
    String? studentClass,
    String? dob,
    int page = 1,
  }) async {
    emit(StudentLoading(currentStatus: status));
    try {
      final response = await repository.fetchStudents(
        schoolId,
        queryParams: {
          if (status != null) 'status': status,
          if (query != null) 'q': query,
          if (studentClass != null) 'class': studentClass,
          if (dob != null) 'dob': dob,
          'page': page,
        },
      );

      emit(
        StudentLoaded(
          students: response.students,
          canUploadImage: response.canUploadImage,
          canRemoveImage: response.canRemoveImage,
          currentPage: response.pagination.currentPage,
          hasMore: response.pagination.hasMorePages,
          query: query,
          currentStatus: status,
          studentClass: studentClass,
          dob: dob,
          canAddAuthority: response.canAddAuthority,
        ),
      );
    } catch (e, stackTrace) {
      emit(
        StudentError(
          'Failed to load students: ${e.toString()}',
          currentStatus: status,
        ),
      );
      addError(e, stackTrace);
    }
  }

  Future<void> _onLoadMoreStudents(
    LoadMoreStudents event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StudentLoaded || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      final response = await repository.fetchStudents(
        event.schoolId,
        queryParams: {
          'page': event.nextPage,
          if (currentState.query != null) 'q': currentState.query!,
          if (currentState.currentStatus != null)
            'status': currentState.currentStatus!,
          if (currentState.studentClass != null)
            'class': currentState.studentClass!,
          if (currentState.dob != null) 'dob': currentState.dob!,
        },
      );

      final allStudents = List.of(currentState.students)
        ..addAll(response.students);

      emit(
        currentState.copyWith(
          students: allStudents,
          currentPage: response.pagination.currentPage,
          hasMore: response.pagination.hasMorePages,
          isLoading: false,
        ),
      );
    } catch (e, stackTrace) {
      emit(StudentError('Failed to load more: ${e.toString()}'));
      addError(e, stackTrace);
    }
  }

  Future<void> _onFetchMoreStudents(
    FetchMoreStudents event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StudentLoaded || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      final response = await repository.filterStudents(
        queryParams: {
          'page': event.nextPage,
          if (currentState.query != null) 'q': currentState.query!,
          if (currentState.currentStatus != null)
            'status': currentState.currentStatus!,
          if (currentState.studentClass != null)
            'class': currentState.studentClass!,
          if (currentState.dob != null) 'dob': currentState.dob!,
        },
      );

      final allStudents = List.of(currentState.students)
        ..addAll(response.students);

      emit(
        currentState.copyWith(
          students: allStudents,
          currentPage: response.pagination.currentPage,
          hasMore: response.pagination.hasMorePages,
          isLoading: false,
        ),
      );
    } catch (e, stackTrace) {
      emit(StudentError('Failed to load more: ${e.toString()}'));
      addError(e, stackTrace);
    }
  }
}
