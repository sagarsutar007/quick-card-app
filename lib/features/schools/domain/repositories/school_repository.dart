import 'package:quickcard/features/schools/data/models/authority_request_model.dart';
import '../../data/models/school_model.dart';

abstract class SchoolRepository {
  Future<List<SchoolModel>> getSchools();
  Future<List<SchoolModel>> searchSchools(String query);
  Future<void> addAuthority(int schoolId, AuthorityRequestModel model);
}
