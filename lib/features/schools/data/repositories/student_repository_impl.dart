import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:quickcard/core/error/exceptions.dart';
import 'package:quickcard/core/network/api_client.dart';
import 'package:quickcard/features/schools/data/datasources/student_remote_data_source.dart';
import 'package:quickcard/features/schools/data/models/student_list_response_model.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final ApiClient apiClient;
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({
    required this.apiClient,
    required this.remoteDataSource,
  });

  @override
  Future<StudentListResponseModel> fetchStudents(
    int schoolId, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await apiClient.get(
      '/schools/$schoolId/students',
      queryParams,
    );

    return StudentListResponseModel.fromJson(response.data);
  }

  @override
  Future<void> uploadPhoto(String studentId, File imageFile) async {
    return remoteDataSource.uploadPhoto(studentId, imageFile);
  }

  @override
  Future<void> removePhoto(String studentId) async {
    try {
      await remoteDataSource.removePhoto(studentId);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    } on SocketException {
      throw NetworkException('No internet connection');
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw PermissionException(e.message ?? 'Permission denied');
      }
      throw UnknownException(e.message ?? 'Unknown error');
    }
  }
}
