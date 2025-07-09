abstract class Failure {
  final String? message;
  Failure([this.message]);
}

class ServerFailure extends Failure {
  ServerFailure([super.message]);
}

class CacheFailure extends Failure {
  CacheFailure([super.message]);
}

class PermissionFailure extends Failure {
  PermissionFailure([super.message]);
}

class UnknownFailure extends Failure {
  UnknownFailure([super.message]);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message]);
}
