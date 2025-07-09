import 'dart:io';

abstract class UploadStudentPhoto {
  Future<void> call({required String studentId, required File imageFile});
}
