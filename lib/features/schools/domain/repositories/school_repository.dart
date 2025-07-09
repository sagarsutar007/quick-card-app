import '../../data/models/school_model.dart';

abstract class SchoolRepository {
  Future<List<SchoolModel>> getSchools();
  Future<List<SchoolModel>> searchSchools(String query);
}
