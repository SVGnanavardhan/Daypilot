import 'package:equatable/equatable.dart';

/// Base class for all application-level exceptions.
///
/// Data sources and infrastructure services should throw subclasses of
/// [AppException]. Higher layers can then convert them into domain failures.
abstract class AppException extends Equatable implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  final String message;
  final String? code;
  final Object? originalError;

  @override
  List<Object?> get props => [
        message,
        code,
        originalError,
      ];

  @override
  String toString() {
    final codeText = code == null ? '' : ' (Code: $code)';
    return '$runtimeType: $message$codeText';
  }
}

/// Exception returned by remote APIs or backend services.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception caused by connectivity, timeout, DNS, or transport failures.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception caused by local database, cache, or persistence failures.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception caused by authentication or authorization failures.
class AppAuthException extends AppException {
  const AppAuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception caused by invalid user or application input.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.originalError,
  });
  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [
        ...super.props,
        fieldErrors,
      ];
}

/// Fallback exception for unexpected application errors.
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
  });
}
