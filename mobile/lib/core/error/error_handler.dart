import 'package:flutter/foundation.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Centralized error mapping and debug logging utility.
///
/// Converts infrastructure/data-layer exceptions into domain failures
/// that can safely be consumed by the presentation layer.
class ErrorHandler {
  ErrorHandler._();

  /// Converts an exception into the corresponding domain failure.
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is CacheException) {
      return CacheFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is AppAuthException) {
      return AuthFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
        fieldErrors: exception.fieldErrors,
      );
    }

    if (exception is UnknownException) {
      return UnknownFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    return UnknownFailure(
      message: exception.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }

  /// Logs an error only in debug builds.
  static void logError(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('DayPilot Error: $error');

    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
