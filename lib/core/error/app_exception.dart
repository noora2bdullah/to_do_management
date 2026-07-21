sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code == null ? message : '$message ($code)';
}

final class AuthAppException extends AppException {
  const AuthAppException(super.message, {super.code});
}

final class DatabaseAppException extends AppException {
  const DatabaseAppException(super.message, {super.code});
}

final class ValidationAppException extends AppException {
  const ValidationAppException(super.message, {super.code});
}

String exceptionMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}
