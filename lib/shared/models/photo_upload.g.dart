// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoUploadAdapter extends TypeAdapter<PhotoUpload> {
  @override
  final int typeId = 0;

  @override
  PhotoUpload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoUpload(
      studentId: fields[0] as String,
      filePath: fields[1] as String,
      status: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoUpload obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.studentId)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoUploadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
