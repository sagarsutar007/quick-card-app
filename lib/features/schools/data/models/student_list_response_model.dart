import 'package:quickcard/features/schools/data/models/student_model.dart';

class StudentListResponseModel {
  final List<StudentModel> students;
  final PaginationModel pagination;
  final bool canUploadImage;
  final bool canRemoveImage;
  final bool canAddAuthority;

  StudentListResponseModel({
    required this.students,
    required this.pagination,
    required this.canUploadImage,
    required this.canRemoveImage,
    required this.canAddAuthority,
  });

  factory StudentListResponseModel.fromJson(Map<String, dynamic> json) {
    return StudentListResponseModel(
      students: (json['students'] as List<dynamic>)
          .map((e) => StudentModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
      canUploadImage: json['permissions']?['can_upload_image'] ?? false,
      canRemoveImage: json['permissions']?['can_remove_image'] ?? false,
      canAddAuthority: json['permissions']?['can_add_authority'] ?? false,
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 30,
      total: json['total'] ?? 0,
      hasMorePages: json['has_more_pages'] ?? false,
    );
  }
}
