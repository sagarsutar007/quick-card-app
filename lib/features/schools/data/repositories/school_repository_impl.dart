import 'package:dio/dio.dart';
import 'package:quickcard/features/schools/data/models/school_model.dart';
import 'package:quickcard/features/schools/domain/repositories/school_repository.dart';

class SchoolRepositoryImpl implements SchoolRepository {
  final Dio dio;

  SchoolRepositoryImpl(this.dio);

  @override
  Future<List<SchoolModel>> getSchools() async {
    final response = await dio.get('/user/schools');
    final data = response.data['schools'] as List;

    return data.map((json) => SchoolModel.fromJson(json)).toList();
  }

  @override
  Future<List<SchoolModel>> searchSchools(String query) async {
    final response = await dio.get(
      '/user/search-schools',
      queryParameters: {'q': query},
    );
    final data = response.data['schools'] as List;

    return data.map((json) => SchoolModel.fromJson(json)).toList();
  }
}
