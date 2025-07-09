abstract class StudentEvent {
  const StudentEvent();
}

class LoadStudents extends StudentEvent {
  final int schoolId;
  final String? status;
  final String? query;
  final String? studentClass;
  final String? dob;

  const LoadStudents(
    this.schoolId, {
    this.status,
    this.query,
    this.studentClass,
    this.dob,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadStudents &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          status == other.status &&
          query == other.query &&
          studentClass == other.studentClass &&
          dob == other.dob;

  @override
  int get hashCode => Object.hash(schoolId, status, query, studentClass, dob);
}

class SearchStudents extends StudentEvent {
  final int schoolId;
  final String query;
  final String? status;
  final String? studentClass;
  final String? dob;

  const SearchStudents(
    this.schoolId,
    this.query, {
    this.status,
    this.studentClass,
    this.dob,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchStudents &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          query == other.query &&
          status == other.status &&
          studentClass == other.studentClass &&
          dob == other.dob;

  @override
  int get hashCode => Object.hash(schoolId, query, status, studentClass, dob);
}

class RefreshStudents extends StudentEvent {
  final int schoolId;
  final String? status;
  final String? studentClass;
  final String? dob;

  const RefreshStudents(
    this.schoolId, {
    this.status,
    this.studentClass,
    this.dob,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshStudents &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          status == other.status &&
          studentClass == other.studentClass &&
          dob == other.dob;

  @override
  int get hashCode => Object.hash(schoolId, status, studentClass, dob);
}

class LoadMoreStudents extends StudentEvent {
  final int schoolId;
  final int nextPage;
  final String? query;
  final String? status;
  final String? studentClass;
  final String? dob;

  const LoadMoreStudents({
    required this.schoolId,
    required this.nextPage,
    this.query,
    this.status,
    this.studentClass,
    this.dob,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadMoreStudents &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          nextPage == other.nextPage &&
          query == other.query &&
          status == other.status &&
          studentClass == other.studentClass &&
          dob == other.dob;

  @override
  int get hashCode =>
      Object.hash(schoolId, nextPage, query, status, studentClass, dob);
}
