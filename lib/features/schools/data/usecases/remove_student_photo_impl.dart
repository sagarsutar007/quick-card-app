import 'package:quickcard/features/schools/domain/usecases/remove_student_photo.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:quickcard/core/error/failures.dart';

class RemoveStudentPhotoImpl implements RemoveStudentPhoto {
  @override
  final StudentRepository repository;

  RemoveStudentPhotoImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(String studentId) async {
    try {
      await repository.removePhoto(studentId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
