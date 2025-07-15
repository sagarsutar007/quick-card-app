import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  Future<Response> post(String path, dynamic data) =>
      dio.post(path, data: data);

  Future<Response> get(String path, [Map<String, dynamic>? params]) async {
    try {
      final response = await dio.get(path, queryParameters: params);
      return response;
    } catch (e) {
      // if (e is DioException && e.response != null) {
      //   final raw = e.response?.data?.toString() ?? 'null';
      //   debugPrint(
      //     'Dio error response data: ${raw.substring(0, raw.length > 1000 ? 1000 : raw.length)}',
      //   );
      // }

      rethrow;
    }
  }

  Future<Response> delete(String path, {Options? options}) =>
      dio.delete(path, options: options);
}
