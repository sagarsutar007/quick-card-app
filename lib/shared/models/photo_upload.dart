import 'package:hive/hive.dart';

part 'photo_upload.g.dart';

@HiveType(typeId: 0)
class PhotoUpload extends HiveObject {
  @HiveField(0)
  String studentId;

  @HiveField(1)
  String filePath;

  @HiveField(2)
  String status; // pending, uploading, uploaded, failed

  @HiveField(3)
  DateTime createdAt;

  PhotoUpload({
    required this.studentId,
    required this.filePath,
    this.status = 'pending',
    required this.createdAt,
  });
}
