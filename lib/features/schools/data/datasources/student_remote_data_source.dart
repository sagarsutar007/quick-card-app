import 'dart:io';

abstract class StudentRemoteDataSource {
  Future<void> uploadPhoto(String studentId, File imageFile);
  Future<void> removePhoto(String studentId);
}
