import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:quickcard/core/error/exceptions.dart';
import 'package:quickcard/core/network/api_client.dart';
import 'package:quickcard/features/schools/data/datasources/student_remote_data_source.dart';
import 'package:quickcard/features/schools/data/models/student_list_response_model.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final ApiClient apiClient;
  final StudentRemoteDataSource remoteDataSource;
  final Box pendingPhotosBox;

  StudentRepositoryImpl({
    required this.apiClient,
    required this.remoteDataSource,
    required this.pendingPhotosBox,
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
  Future<StudentListResponseModel> filterStudents({
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri(
      path: '/all-students',
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );

    // Debug print full URL and query params
    print('[DEBUG] GET ${uri.toString()}');
    print('[DEBUG] Query Params: $queryParams');

    final response = await apiClient.get('/all-students', queryParams);

    return StudentListResponseModel.fromJson(response.data);
  }

  @override
  Future<void> uploadPhoto(String studentId, File imageFile) async {
    try {
      await remoteDataSource.uploadPhoto(studentId, imageFile);
      await pendingPhotosBox.delete(studentId);
    } on NetworkException {
      await pendingPhotosBox.put(studentId, {
        'studentId': studentId,
        'photoPath': imageFile.path,
        'status': 'pending_upload',
        'createdAt': DateTime.now().toIso8601String(),
      });
      rethrow;
    }
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
