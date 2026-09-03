import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

/// Provides the configured HTTP client used across DayPilot.
final dioClientProvider = Provider<Dio>(
  (ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.apiConnectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.apiTimeout,
        ),
        sendTimeout: const Duration(
          milliseconds: AppConstants.apiTimeout,
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
        ),
    ]);

    return dio;
  },
  name: 'dioClientProvider',
);

/// Adds authentication information to outgoing requests.
///
/// Actual Supabase access-token integration will be connected
/// in the authentication foundation.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    handler.next(err);
  }
}
