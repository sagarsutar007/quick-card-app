import 'dart:io';
import 'package:dio/dio.dart';
import 'package:quickcard/core/network/api_client.dart';
import 'package:quickcard/core/error/exceptions.dart';
import 'package:quickcard/features/schools/data/datasources/student_remote_data_source.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiClient apiClient;

  StudentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> uploadPhoto(String studentId, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'student_$studentId.jpg',
        ),
        'student_id': studentId,
      });

      await apiClient.post('/students/upload-photo', formData);
    } on DioException catch (e) {
      _handleDioException(e, 'Failed to upload photo');
    } catch (e) {
      throw ServerException('Failed to upload photo: ${e.toString()}');
    }
  }

  @override
  Future<void> removePhoto(String studentId) async {
    try {
      await apiClient.delete(
        '/students/$studentId/photo',
        options: Options(headers: {'Accept': 'application/json'}),
      );
    } on DioException catch (e) {
      _handleDioException(e, 'Failed to remove photo');
    } catch (e) {
      throw ServerException('Failed to remove photo: ${e.toString()}');
    }
  }

  void _handleDioException(DioException e, String defaultMessage) {
    if (e.response?.statusCode == 401) {
      throw UnauthorizedException();
    } else if (e.response?.statusCode == 404) {
      throw NotFoundException(
        e.response?.data['message'] ?? 'Resource not found',
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('Connection timeout');
    } else if (e.type == DioExceptionType.unknown) {
      throw NetworkException('No internet connection');
    } else if (e.response?.statusCode == 422) {
      throw ValidationException(
        Map<String, dynamic>.from(e.response?.data['errors'] ?? {}),
      );
    } else {
      throw ServerException(
        e.response?.data['message']?.toString() ?? defaultMessage,
      );
    }
  }
}
