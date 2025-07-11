class StudentModel {
  final int id;
  final String name;
  final String studentCode;
  final String? dob;
  final String? photo;
  final String? className;
  final int schoolId;
  final String? schoolName;
  final String? updatedAt;

  StudentModel({
    required this.id,
    required this.name,
    required this.studentCode,
    this.dob,
    this.photo,
    this.className,
    required this.schoolId,
    required this.schoolName,
    this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      studentCode: json['student_code'] as String,
      dob: json['dob'] as String?,
      photo: json['photo'] as String?,
      className: json['class'] as String?,
      schoolId: json['school_id'] as int,
      schoolName: json['school_name'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }
}
