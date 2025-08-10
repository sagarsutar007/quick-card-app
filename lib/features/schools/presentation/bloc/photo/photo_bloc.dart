import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcard/core/error/failures.dart';
import 'package:quickcard/features/schools/domain/usecases/remove_student_photo.dart';
import 'package:quickcard/features/schools/presentation/bloc/photo/photo_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/photo/photo_state.dart';
import 'package:quickcard/features/schools/domain/usecases/upload_student_photo.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final UploadStudentPhoto uploadStudentPhoto;
  final RemoveStudentPhoto removeStudentPhoto;

  PhotoBloc({
    required this.uploadStudentPhoto,
    required this.removeStudentPhoto,
  }) : super(PhotoInitial()) {
    on<UploadPhotoRequested>(_onUploadPhotoRequested);
    on<RemovePhotoRequested>(_onRemovePhotoRequested);
  }

  Future<void> _onUploadPhotoRequested(
    UploadPhotoRequested event,
    Emitter<PhotoState> emit,
  ) async {
    emit(PhotoUploadInProgress());

    try {
      await uploadStudentPhoto(
        studentId: event.studentId,
        imageFile: event.imageFile,
      );
      emit(PhotoUploadSuccess());
    } catch (e) {
      String message;
      if (e is Failure) {
        message = e.message ?? 'Unknown error occurred';
      } else if (e is Exception) {
        message = e.toString();
      } else {
        message = 'Unexpected error: $e';
      }
      emit(PhotoUploadFailure(message));
    }
  }

  Future<void> _onRemovePhotoRequested(
    RemovePhotoRequested event,
    Emitter<PhotoState> emit,
  ) async {
    emit(PhotoRemoveInProgress());
    final result = await removeStudentPhoto(event.studentId);

    result.fold((failure) {
      if (failure is PermissionFailure) {
        emit(PhotoRemoveFailure('Please grant storage permission'));
      } else if (failure is NetworkFailure) {
        emit(
          PhotoRemoveFailure(
            'Network error: ${failure.message ?? 'Unknown network error'}',
          ),
        );
      } else {
        emit(PhotoRemoveFailure(failure.message ?? 'Unknown error'));
      }
    }, (_) => emit(PhotoRemoveSuccess()));
  }
}
