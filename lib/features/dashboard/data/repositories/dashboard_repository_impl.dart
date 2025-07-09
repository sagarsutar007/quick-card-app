import 'package:dio/dio.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio dio;

  DashboardRepositoryImpl(this.dio);

  @override
  Future<DashboardModel> fetchDashboard() async {
    final response = await dio.get('/dashboard');
    return DashboardModel.fromJson(response.data);
  }
}
