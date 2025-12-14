class DashboardModel {
  final int schoolCount;
  final int studentCount;
  final int studentsWithPhoto;
  final int studentsWithoutPhoto;
  final List<Activity> latestActivities;
  final List<SchoolBasicInfo> schoolBasicInfo;

  DashboardModel({
    required this.schoolCount,
    required this.studentCount,
    required this.studentsWithPhoto,
    required this.studentsWithoutPhoto,
    required this.latestActivities,
    required this.schoolBasicInfo,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      schoolCount: json['school_count'],
      studentCount: json['student_count'],
      studentsWithPhoto: json['students_with_photo'],
      studentsWithoutPhoto: json['students_without_photo'],
      latestActivities: List<Activity>.from(
        json['latest_activities'].map((x) => Activity.fromJson(x)),
      ),
      schoolBasicInfo: List<SchoolBasicInfo>.from(
        json['school_basic_info'].map((x) => SchoolBasicInfo.fromJson(x)),
      ),
    );
  }
}

class Activity {
  final int id;
  final String action;
  final String description;
  final String ipAddress;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.action,
    required this.description,
    required this.ipAddress,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      action: json['action'],
      description: json['description'],
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class SchoolBasicInfo {
  final int id;
  final String name;
  final String? address;
  final String? schoolCode;
  final int missingPhotosCount;
  final int havingPhotosCount;
  final int studentsCount;

  SchoolBasicInfo({
    required this.id,
    required this.name,
    this.address,
    this.schoolCode,
    required this.missingPhotosCount,
    required this.havingPhotosCount,
    required this.studentsCount,
  });

  factory SchoolBasicInfo.fromJson(Map<String, dynamic> json) {
    return SchoolBasicInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed School',
      address: json['school_address'],
      schoolCode: json['school_code'],
      missingPhotosCount: json['students_without_photo_count'] ?? 0,
      havingPhotosCount: json['students_with_photo_count'] ?? 0,
      studentsCount: json['students_count'] ?? 0,
    );
  }
}
