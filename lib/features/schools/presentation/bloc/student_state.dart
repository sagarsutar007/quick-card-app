import 'package:flutter/foundation.dart';
import 'package:quickcard/features/schools/data/models/student_model.dart';

abstract class StudentState {
  const StudentState();
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  final String? currentStatus;

  const StudentLoading({this.currentStatus});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentLoading &&
          runtimeType == other.runtimeType &&
          currentStatus == other.currentStatus;

  @override
  int get hashCode => currentStatus.hashCode;
}

class StudentLoaded extends StudentState {
  final List<StudentModel> students;
  final bool canUploadImage;
  final bool canRemoveImage;
  final int currentPage;
  final bool hasMore;
  final String? query;
  final String? currentStatus;
  final String? studentClass;
  final String? dob;
  final int? lock;
  final bool isLoading;
  final bool canAddAuthority;

  const StudentLoaded({
    required this.students,
    required this.canUploadImage,
    required this.canRemoveImage,
    required this.currentPage,
    required this.hasMore,
    this.query,
    this.currentStatus,
    this.studentClass,
    this.dob,
    this.lock,
    this.isLoading = false,
    required this.canAddAuthority,
  });

  StudentLoaded copyWith({
    List<StudentModel>? students,
    bool? canUploadImage,
    bool? canRemoveImage,
    int? currentPage,
    bool? hasMore,
    String? query,
    String? currentStatus,
    String? studentClass,
    String? dob,
    int? lock,
    bool? isLoading,
    bool? canAddAuthority,
  }) {
    return StudentLoaded(
      students: students ?? this.students,
      canUploadImage: canUploadImage ?? this.canUploadImage,
      canRemoveImage: canRemoveImage ?? this.canRemoveImage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      currentStatus: currentStatus ?? this.currentStatus,
      studentClass: studentClass ?? this.studentClass,
      dob: dob ?? this.dob,
      lock: lock ?? this.lock,
      isLoading: isLoading ?? this.isLoading,
      canAddAuthority: canAddAuthority ?? this.canAddAuthority,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(students, other.students) &&
          canUploadImage == other.canUploadImage &&
          canRemoveImage == other.canRemoveImage &&
          currentPage == other.currentPage &&
          hasMore == other.hasMore &&
          query == other.query &&
          currentStatus == other.currentStatus &&
          studentClass == other.studentClass &&
          dob == other.dob &&
          lock == other.lock &&
          isLoading == other.isLoading &&
          canAddAuthority == other.canAddAuthority;

  @override
  int get hashCode => Object.hash(
    students,
    canUploadImage,
    canRemoveImage,
    currentPage,
    hasMore,
    query,
    currentStatus,
    studentClass,
    dob,
    lock,
    isLoading,
    canAddAuthority,
  );
}

class StudentError extends StudentState {
  final String message;
  final String? errorCode;
  final String? currentStatus;

  const StudentError(this.message, {this.errorCode, this.currentStatus});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          errorCode == other.errorCode &&
          currentStatus == other.currentStatus;

  @override
  int get hashCode => Object.hash(message, errorCode, currentStatus);
}
