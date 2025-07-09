import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object> get props => [];
}

class UploadPhotoRequested extends PhotoEvent {
  final String studentId;
  final File imageFile;

  const UploadPhotoRequested({
    required this.studentId,
    required this.imageFile,
  });

  @override
  List<Object> get props => [studentId, imageFile];
}

class RemovePhotoRequested extends PhotoEvent {
  final String studentId;

  const RemovePhotoRequested(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class PhotoReset extends PhotoEvent {}
