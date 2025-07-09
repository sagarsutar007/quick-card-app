import 'package:quickcard/features/schools/data/models/school_model.dart';

abstract class SchoolState {}

class SchoolInitial extends SchoolState {}

class SchoolLoading extends SchoolState {}

class SchoolLoaded extends SchoolState {
  final List<SchoolModel> schools;

  SchoolLoaded(this.schools);
}

class SchoolError extends SchoolState {
  final String message;

  SchoolError(this.message);
}
