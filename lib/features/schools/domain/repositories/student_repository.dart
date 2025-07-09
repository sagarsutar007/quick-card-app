import 'package:quickcard/features/schools/data/models/student_list_response_model.dart';
import 'dart:io';

abstract class StudentRepository {
  Future<StudentListResponseModel> fetchStudents(
    int schoolId, {
    Map<String, dynamic>? queryParams,
  });

  Future<void> uploadPhoto(String studentId, File imageFile);
  Future<void> removePhoto(String studentId);
}
