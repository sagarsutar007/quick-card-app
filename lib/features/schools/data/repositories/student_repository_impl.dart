import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:quickcard/core/error/exceptions.dart';
import 'package:quickcard/core/network/api_client.dart';
import 'package:quickcard/features/schools/data/datasources/student_remote_data_source.dart';
import 'package:quickcard/features/schools/data/models/student_list_response_model.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';
import 'package:quickcard/shared/models/photo_upload.dart';

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
    final photoUpload = PhotoUpload(
      studentId: studentId,
      filePath: imageFile.path,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await pendingPhotosBox.put(studentId, photoUpload);

    try {
      await remoteDataSource.uploadPhoto(studentId, imageFile);
      await pendingPhotosBox.delete(studentId);
    } catch (e) {
      await pendingPhotosBox.put(studentId, photoUpload);
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

  Future<void> retryPendingUploads() async {
    final pendingPhotos = pendingPhotosBox.values.toList();

    for (final photo in pendingPhotos) {
      try {
        final studentId = photo.studentId;
        final photoPath = photo.filePath;

        final file = File(photoPath);
        if (!file.existsSync()) {
          await pendingPhotosBox.delete(studentId);
          continue;
        }

        await remoteDataSource.uploadPhoto(studentId, file);
        await pendingPhotosBox.delete(studentId);
        print('[RETRY] Successfully uploaded for student $studentId');
      } catch (e) {
        print('[RETRY] Failed for student ${photo.studentId}: $e');
        // Leave it in Hive for next retry
      }
    }
  }
}
