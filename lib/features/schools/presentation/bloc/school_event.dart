abstract class SchoolEvent {}

class LoadSchools extends SchoolEvent {}

class SearchSchools extends SchoolEvent {
  final String query;

  SearchSchools(this.query);
}
