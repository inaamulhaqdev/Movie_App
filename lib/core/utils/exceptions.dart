class AppException implements Exception {
  final String message;
  final String? code;
  final Exception? originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class ApiException extends AppException {
  ApiException(super.message, {super.code, super.originalError});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.originalError});
}
