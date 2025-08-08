import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:quickcard/shared/models/photo_upload.dart';
import 'package:path_provider/path_provider.dart';

class PhotoUploadQueue {
  final Dio _dio;
  final String _baseUrl;
  final String _token;

  PhotoUploadQueue(this._dio, this._baseUrl, this._token);

  Future<void> addToQueue(String studentId, File photoFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newPath =
        '${appDir.path}/${studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await photoFile.copy(newPath);

    final box = Hive.box<PhotoUpload>('photo_uploads');
    await box.add(
      PhotoUpload(
        studentId: studentId,
        filePath: newPath,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> processQueue() async {
    final box = Hive.box<PhotoUpload>('photo_uploads');
    final pending = box.values.where((p) => p.status == 'pending').toList();

    for (final photo in pending) {
      try {
        photo.status = 'uploading';
        await photo.save();

        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(photo.filePath),
        });

        final response = await _dio.post(
          '$_baseUrl/students/${photo.studentId}/upload-photo',
          data: formData,
          options: Options(headers: {'Authorization': 'Bearer $_token'}),
        );

        if (response.statusCode == 200) {
          photo.status = 'uploaded';
          await photo.save();
        } else {
          photo.status = 'failed';
          await photo.save();
        }
      } catch (_) {
        photo.status = 'failed';
        await photo.save();
      }
    }
  }

  void startNetworkListener() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status.isNotEmpty && !status.contains(ConnectivityResult.none)) {
        processQueue();
      }
    });
  }
}
