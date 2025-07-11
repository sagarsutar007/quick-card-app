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

class FetchStudents extends StudentEvent {
  final String? query;
  final String? status;
  final String? studentClass;
  final String? dob;
  final int page;
  final bool isRefresh;

  const FetchStudents({
    this.query,
    this.status,
    this.studentClass,
    this.dob,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  String toString() {
    return 'FetchStudents(status: $status, query: $query, class: $studentClass, dob: $dob, page: $page)';
  }
}

class FetchMoreStudents extends StudentEvent {
  final int nextPage;
  final String? query;
  final String? status;
  final String? studentClass;
  final String? dob;

  const FetchMoreStudents({
    required this.nextPage,
    this.query,
    this.status,
    this.studentClass,
    this.dob,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchMoreStudents &&
          runtimeType == other.runtimeType &&
          nextPage == other.nextPage &&
          query == other.query &&
          status == other.status &&
          studentClass == other.studentClass &&
          dob == other.dob;

  @override
  int get hashCode => Object.hash(nextPage, query, status, studentClass, dob);
}
