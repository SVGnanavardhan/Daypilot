// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';

part 'auth_provider.g.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  verifyingEmail,
  passwordRecovery,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.verificationEmail,
    this.recoveryEmail,
  });

  final AuthStatus status;
  final User? user;
  final Failure? error;

  /// Email waiting for signup OTP verification.
  final String? verificationEmail;

  /// Email currently going through forgot-password OTP recovery.
  final String? recoveryEmail;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? error,
    String? verificationEmail,
    String? recoveryEmail,
    bool clearUser = false,
    bool clearError = false,
    bool clearVerificationEmail = false,
    bool clearRecoveryEmail = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      error: clearError ? null : error ?? this.error,
      verificationEmail: clearVerificationEmail
          ? null
          : verificationEmail ?? this.verificationEmail,
      recoveryEmail:
          clearRecoveryEmail ? null : recoveryEmail ?? this.recoveryEmail,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRemoteDataSource _remoteDataSource;
  late final AuthRepositoryImpl _repository;

  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GoogleSignInUseCase _googleSignInUseCase;
  late final SendPasswordResetUseCase _sendPasswordResetUseCase;
  late final UpdatePasswordUseCase _updatePasswordUseCase;

  StreamSubscription<User?>? _authSubscription;

  bool _isPasswordRecoveryActive = false;

  @override
  AuthState build() {
    _remoteDataSource = AuthRemoteDataSource();

    _repository = AuthRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _logoutUseCase = LogoutUseCase(_repository);
    _googleSignInUseCase = GoogleSignInUseCase(_repository);
    _sendPasswordResetUseCase = SendPasswordResetUseCase(_repository);
    _updatePasswordUseCase = UpdatePasswordUseCase(_repository);

    final previousSubscription = _authSubscription;

    if (previousSubscription != null) {
      unawaited(
        previousSubscription.cancel(),
      );
    }

    _authSubscription = _repository.authStateChanges.listen(
      _handleAuthChange,
      onError: (_) {
        if (_isPasswordRecoveryActive) {
          return;
        }

        if (state.status == AuthStatus.verifyingEmail &&
            state.verificationEmail != null) {
          return;
        }

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      },
    );

    ref.onDispose(() {
      final subscription = _authSubscription;

      if (subscription != null) {
        unawaited(
          subscription.cancel(),
        );
      }
    });

    unawaited(
      Future<void>.microtask(
        _checkAuthStatus,
      ),
    );

    return const AuthState();
  }

  void _handleAuthChange(User? user) {
    if (user == null) {
      if (_isPasswordRecoveryActive) {
        return;
      }

      if (state.status == AuthStatus.verifyingEmail &&
          state.verificationEmail != null) {
        return;
      }

      /*
       * During forgot-password OTP entry there is intentionally no active
       * Supabase session yet. Preserve the recovery email so the OTP screen
       * continues to work.
       */
      if (state.recoveryEmail != null &&
          state.recoveryEmail!.trim().isNotEmpty) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );

        return;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      );

      return;
    }

    if (_isPasswordRecoveryActive) {
      state = state.copyWith(
        status: AuthStatus.passwordRecovery,
        user: user,
        clearError: true,
      );

      return;
    }

    state = state.copyWith(
      status: _statusForUser(user),
      user: user,
      clearError: true,
    );
  }

  AuthStatus _statusForUser(User user) {
    return user.isEmailVerified
        ? AuthStatus.authenticated
        : AuthStatus.verifyingEmail;
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final result = await _repository.getCurrentUser();

    result.fold(
      (failure) {
        if (_isPasswordRecoveryActive) {
          state = state.copyWith(
            status: AuthStatus.passwordRecovery,
            error: failure,
          );

          return;
        }

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure,
          clearUser: true,
        );
      },
      (user) {
        if (_isPasswordRecoveryActive) {
          state = state.copyWith(
            status: AuthStatus.passwordRecovery,
            user: user,
            clearError: true,
          );

          return;
        }

        if (user == null) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            clearError: true,
          );

          return;
        }

        state = state.copyWith(
          status: _statusForUser(user),
          user: user,
          clearError: true,
        );
      },
    );
  }

  Future<Failure?> login({
    required String email,
    required String password,
  }) async {
    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearVerificationEmail: true,
      clearRecoveryEmail: true,
    );

    final result = await _loginUseCase(
      email: email.trim(),
      password: password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure,
          clearUser: true,
        );

        return failure;
      },
      (authResult) {
        final user = authResult.user;

        if (!user.isEmailVerified) {
          state = state.copyWith(
            status: AuthStatus.verifyingEmail,
            user: user,
            verificationEmail: user.email,
            clearError: true,
          );

          return null;
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
          clearVerificationEmail: true,
          clearRecoveryEmail: true,
        );

        return null;
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim();

    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearRecoveryEmail: true,
    );

    final result = await _registerUseCase(
      email: normalizedEmail,
      password: password,
      displayName: displayName.trim(),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure,
          clearUser: true,
          clearVerificationEmail: true,
        );
      },
      (authResult) {
        if (authResult.user.isEmailVerified) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: authResult.user,
            clearError: true,
            clearVerificationEmail: true,
          );

          return;
        }

        state = state.copyWith(
          status: AuthStatus.verifyingEmail,
          user: authResult.user,
          verificationEmail: normalizedEmail,
          clearError: true,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SIGNUP EMAIL OTP
  // ---------------------------------------------------------------------------

  Future<bool> verifyEmailOtp({
    required String token,
  }) async {
    final email = state.verificationEmail ?? state.user?.email;

    if (email == null || email.trim().isEmpty) {
      state = state.copyWith(
        status: AuthStatus.verifyingEmail,
        error: const AuthFailure(
          message: 'Verification email is unavailable. Please register again.',
          code: 'VERIFICATION_EMAIL_MISSING',
        ),
      );

      return false;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    try {
      final response = await _remoteDataSource.verifyEmailOtp(
        email: email.trim(),
        token: token.trim(),
      );

      final supabaseUser = response.user;

      if (supabaseUser == null) {
        throw const AppAuthException(
          message: 'Unable to verify your email.',
          code: 'NO_VERIFIED_USER',
        );
      }

      final user = UserModel.fromSupabaseUser(
        supabaseUser,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
        clearVerificationEmail: true,
        clearRecoveryEmail: true,
      );

      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.verifyingEmail,
        error: ErrorHandler.handleException(error),
      );

      return false;
    } catch (error, stackTrace) {
      ErrorHandler.logError(
        error,
        stackTrace,
      );

      state = state.copyWith(
        status: AuthStatus.verifyingEmail,
        error: const UnknownFailure(
          message: 'Unable to verify the email code. Please try again.',
          code: 'EMAIL_OTP_UNKNOWN_ERROR',
        ),
      );

      return false;
    }
  }

  Future<bool> resendEmailVerificationOtp() async {
    final email = state.verificationEmail ?? state.user?.email;

    if (email == null || email.trim().isEmpty) {
      state = state.copyWith(
        error: const AuthFailure(
          message: 'Verification email is unavailable.',
          code: 'VERIFICATION_EMAIL_MISSING',
        ),
      );

      return false;
    }

    try {
      await _remoteDataSource.resendEmailVerificationOtp(
        email: email.trim(),
      );

      state = state.copyWith(
        status: AuthStatus.verifyingEmail,
        verificationEmail: email.trim(),
        clearError: true,
      );

      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.verifyingEmail,
        error: ErrorHandler.handleException(error),
      );

      return false;
    } catch (error, stackTrace) {
      ErrorHandler.logError(
        error,
        stackTrace,
      );

      state = state.copyWith(
        status: AuthStatus.verifyingEmail,
        error: const UnknownFailure(
          message: 'Unable to resend verification code.',
          code: 'EMAIL_OTP_RESEND_UNKNOWN_ERROR',
        ),
      );

      return false;
    }
  }

  /// Screen-compatible wrapper.
  Future<bool> verifyOtp(String otp) {
    return verifyEmailOtp(
      token: otp,
    );
  }

  /// Screen-compatible wrapper.
  Future<bool> resendOtp() {
    return resendEmailVerificationOtp();
  }

  // ---------------------------------------------------------------------------
  // GOOGLE SIGN IN
  // ---------------------------------------------------------------------------

  Future<void> signInWithGoogle() async {
    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearVerificationEmail: true,
      clearRecoveryEmail: true,
    );

    final result = await _googleSignInUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure,
          clearUser: true,
        );
      },
      (authResult) {
        state = state.copyWith(
          status: _statusForUser(authResult.user),
          user: authResult.user,
          clearError: true,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    final previousUser = state.user;
    final wasRecoveringPassword = _isPasswordRecoveryActive;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: wasRecoveringPassword
              ? AuthStatus.passwordRecovery
              : previousUser == null
                  ? AuthStatus.unauthenticated
                  : _statusForUser(previousUser),
          user: previousUser,
          error: failure,
        );
      },
      (_) {
        _isPasswordRecoveryActive = false;

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
          clearVerificationEmail: true,
          clearRecoveryEmail: true,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PASSWORD RESET OTP
  // ---------------------------------------------------------------------------

  /// Sends the forgot-password OTP.
  ///
  /// IMPORTANT:
  /// We intentionally remain unauthenticated after sending the OTP.
  /// `passwordRecovery` status is entered only after the OTP is verified.
  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    final normalizedEmail = email.trim();

    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearUser: true,
      clearVerificationEmail: true,
    );

    final result = await _sendPasswordResetUseCase(
      email: normalizedEmail,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure,
          recoveryEmail: normalizedEmail,
          clearUser: true,
        );

        return false;
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          recoveryEmail: normalizedEmail,
          clearUser: true,
          clearError: true,
        );

        return true;
      },
    );
  }

  /// Screen-compatible OTP naming.
  Future<bool> sendPasswordResetOtp({
    required String email,
  }) {
    return sendPasswordResetEmail(
      email: email,
    );
  }

  /// Verifies the recovery OTP.
  ///
  /// Only after successful verification do we enter passwordRecovery status.
  Future<bool> verifyPasswordRecoveryOtp({
    required String token,
  }) async {
    final email = state.recoveryEmail;

    if (email == null || email.trim().isEmpty) {
      _isPasswordRecoveryActive = false;

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: const AuthFailure(
          message:
              'Recovery email is unavailable. Start password recovery again.',
          code: 'RECOVERY_EMAIL_MISSING',
        ),
      );

      return false;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    /*
     * Set this before verifyOTP because Supabase may emit an auth-state event
     * as soon as the recovery session is created.
     */
    _isPasswordRecoveryActive = true;

    try {
      final response = await _remoteDataSource.verifyPasswordRecoveryOtp(
        email: email.trim(),
        token: token.trim(),
      );

      final supabaseUser = response.user;

      if (supabaseUser == null || response.session == null) {
        throw const AppAuthException(
          message: 'Unable to verify the recovery code.',
          code: 'INVALID_RECOVERY_SESSION',
        );
      }

      final user = UserModel.fromSupabaseUser(
        supabaseUser,
      );

      state = state.copyWith(
        status: AuthStatus.passwordRecovery,
        user: user,
        recoveryEmail: email.trim(),
        clearError: true,
      );

      return true;
    } on AppException catch (error) {
      _isPasswordRecoveryActive = false;

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        recoveryEmail: email.trim(),
        error: ErrorHandler.handleException(error),
        clearUser: true,
      );

      return false;
    } catch (error, stackTrace) {
      ErrorHandler.logError(
        error,
        stackTrace,
      );

      _isPasswordRecoveryActive = false;

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        recoveryEmail: email.trim(),
        error: const UnknownFailure(
          message: 'Unable to verify the recovery code. Please try again.',
          code: 'RECOVERY_OTP_UNKNOWN_ERROR',
        ),
        clearUser: true,
      );

      return false;
    }
  }

  /// Screen-compatible method.
  Future<bool> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: const AuthFailure(
          message: 'Recovery email is unavailable.',
          code: 'RECOVERY_EMAIL_MISSING',
        ),
      );

      return false;
    }

    /*
     * The route passes the email explicitly. Store it to make this method
     * resilient even if provider state was rebuilt before the OTP screen.
     */
    state = state.copyWith(
      recoveryEmail: normalizedEmail,
      clearError: true,
    );

    return verifyPasswordRecoveryOtp(
      token: otp,
    );
  }

  Future<bool> resendPasswordRecoveryOtp() async {
    final email = state.recoveryEmail;

    if (email == null || email.trim().isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: const AuthFailure(
          message:
              'Recovery email is unavailable. Start password recovery again.',
          code: 'RECOVERY_EMAIL_MISSING',
        ),
      );

      return false;
    }

    _isPasswordRecoveryActive = false;

    final result = await _sendPasswordResetUseCase(
      email: email.trim(),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          recoveryEmail: email.trim(),
          error: failure,
          clearUser: true,
        );

        return false;
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          recoveryEmail: email.trim(),
          clearError: true,
          clearUser: true,
        );

        return true;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    _isPasswordRecoveryActive = true;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final result = await _updatePasswordUseCase(
      newPassword: newPassword,
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.passwordRecovery,
          error: failure,
        );
      },
      (_) async {
        final logoutResult = await _logoutUseCase();

        logoutResult.fold(
          (failure) {
            _isPasswordRecoveryActive = false;

            state = state.copyWith(
              status: AuthStatus.authenticated,
              error: failure,
              clearRecoveryEmail: true,
            );
          },
          (_) {
            _isPasswordRecoveryActive = false;

            state = state.copyWith(
              status: AuthStatus.unauthenticated,
              clearUser: true,
              clearError: true,
              clearRecoveryEmail: true,
              clearVerificationEmail: true,
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TEMPORARY COMPATIBILITY
  // ---------------------------------------------------------------------------

  Future<void> sendEmailVerification() async {
    await resendEmailVerificationOtp();
  }

  Future<void> reloadUser() async {
    final result = await _repository.reloadUser();

    result.fold(
      (failure) {
        state = state.copyWith(
          error: failure,
        );
      },
      (user) {
        state = state.copyWith(
          status: _isPasswordRecoveryActive
              ? AuthStatus.passwordRecovery
              : _statusForUser(user),
          user: user,
          clearError: true,
        );
      },
    );
  }

  void cancelPasswordRecovery() {
    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
      clearRecoveryEmail: true,
    );
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }
}
