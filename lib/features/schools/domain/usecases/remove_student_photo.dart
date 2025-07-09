import 'package:dartz/dartz.dart';
import 'package:quickcard/core/error/failures.dart';
import 'package:quickcard/core/error/exceptions.dart';
import 'package:quickcard/core/usecases/usecase.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';

class RemoveStudentPhoto implements UseCase<void, String> {
  final StudentRepository repository;

  RemoveStudentPhoto(this.repository);

  @override
  Future<Either<Failure, void>> call(String studentId) async {
    try {
      await repository.removePhoto(studentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on PermissionException {
      return Left(PermissionFailure('Storage permission denied'));
    } catch (e) {
      return Left(UnknownFailure('Failed to remove photo: ${e.toString()}'));
    }
  }
}
