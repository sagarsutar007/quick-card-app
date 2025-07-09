import 'package:equatable/equatable.dart';

abstract class PhotoState extends Equatable {
  const PhotoState();

  @override
  List<Object> get props => [];
}

class PhotoInitial extends PhotoState {}

class PhotoUploadInProgress extends PhotoState {
  final double progress;

  const PhotoUploadInProgress([this.progress = 0.0]);

  @override
  List<Object> get props => [progress];
}

class PhotoUploadSuccess extends PhotoState {
  final String imageUrl;

  const PhotoUploadSuccess([this.imageUrl = '']);

  @override
  List<Object> get props => [imageUrl];
}

class PhotoUploadFailure extends PhotoState {
  final String error;

  const PhotoUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class PhotoRemoveInProgress extends PhotoState {}

class PhotoRemoveSuccess extends PhotoState {}

class PhotoRemoveFailure extends PhotoState {
  final String error;

  const PhotoRemoveFailure(this.error);

  @override
  List<Object> get props => [error];
}
