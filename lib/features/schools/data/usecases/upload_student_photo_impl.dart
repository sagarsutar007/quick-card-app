import 'dart:io';

import 'package:quickcard/features/schools/domain/usecases/upload_student_photo.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';

class UploadStudentPhotoImpl implements UploadStudentPhoto {
  final StudentRepository repository;

  UploadStudentPhotoImpl(this.repository);

  @override
  Future<void> call({
    required String studentId,
    required File imageFile,
  }) async {
    await repository.uploadPhoto(studentId, imageFile);
  }
}
