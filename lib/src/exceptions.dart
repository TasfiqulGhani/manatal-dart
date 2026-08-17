/// Exception types raised by the Manatal client.
library;

class ManatalException implements Exception {
  ManatalException(
    this.message, {
    this.statusCode,
    this.body,
    this.headers = const {},
  });

  final String message;
  final int? statusCode;
  final Object? body;
  final Map<String, String> headers;

  @override
  String toString() => message;
}

class AuthenticationException extends ManatalException {
  AuthenticationException(
    super.message, {
    super.statusCode,
    super.body,
    super.headers,
  });
}

class ForbiddenException extends ManatalException {
  ForbiddenException(
    super.message, {
    super.statusCode,
    super.body,
    super.headers,
  });
}

class NotFoundException extends ManatalException {
  NotFoundException(
    super.message, {
    super.statusCode,
    super.body,
    super.headers,
  });
}

class ValidationException extends ManatalException {
  ValidationException(
    super.message, {
    super.statusCode,
    super.body,
    super.headers,
  });
}

class RateLimitException extends ManatalException {
  RateLimitException(
    super.message, {
    super.statusCode,
    super.body,
    super.headers,
    this.retryAfter,
  });

  final double? retryAfter;
}

class ApiException extends ManatalException {
  ApiException(
    super.message, {
    super.statusCode,
    super.body,
    super.headers,
  });
}
