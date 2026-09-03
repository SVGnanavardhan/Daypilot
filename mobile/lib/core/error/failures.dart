import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// Failures are safe error objects passed from repositories/use cases
/// to the presentation layer.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;

  @override
  List<Object?> get props => [
        message,
        code,
      ];

  @override
  String toString() {
    final codeText = code == null ? '' : ' (Code: $code)';
    return '$runtimeType: $message$codeText';
  }
}

/// Failure caused by backend or remote service errors.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Failure caused by network or connectivity problems.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Failure caused by local storage, cache, or database errors.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Failure caused by authentication or authorization problems.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

/// Failure caused by invalid input.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });
  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [
        ...super.props,
        fieldErrors,
      ];
}

/// Fallback failure for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
  });
}
