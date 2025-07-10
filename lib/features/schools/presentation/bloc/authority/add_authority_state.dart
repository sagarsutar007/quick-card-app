abstract class AddAuthorityState {}

class AddAuthorityInitial extends AddAuthorityState {}

class AddAuthorityLoading extends AddAuthorityState {}

class AddAuthoritySuccess extends AddAuthorityState {}

class AddAuthorityFailure extends AddAuthorityState {
  final String message;
  AddAuthorityFailure(this.message);
}
