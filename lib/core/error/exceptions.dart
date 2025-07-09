class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Resource not found']);
  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final Map<String, dynamic> errors;

  ValidationException(this.errors);
}
