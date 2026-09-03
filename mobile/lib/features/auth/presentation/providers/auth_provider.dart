// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
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
  });

  final AuthStatus status;
  final User? user;
  final Failure? error;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      error: clearError ? null : error ?? this.error,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRepositoryImpl _repository;

  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GoogleSignInUseCase _googleSignInUseCase;
  late final SendPasswordResetUseCase _sendPasswordResetUseCase;
  late final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  late final UpdatePasswordUseCase _updatePasswordUseCase;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<void>? _passwordRecoverySubscription;

  bool _isPasswordRecoveryActive = false;

  @override
  AuthState build() {
    final remoteDataSource = AuthRemoteDataSource();

    _repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _logoutUseCase = LogoutUseCase(_repository);
    _googleSignInUseCase = GoogleSignInUseCase(_repository);
    _sendPasswordResetUseCase = SendPasswordResetUseCase(_repository);
    _sendEmailVerificationUseCase = SendEmailVerificationUseCase(_repository);
    _updatePasswordUseCase = UpdatePasswordUseCase(_repository);

    final previousAuthSubscription = _authSubscription;

    if (previousAuthSubscription != null) {
      unawaited(
        previousAuthSubscription.cancel(),
      );
    }

    final previousRecoverySubscription = _passwordRecoverySubscription;

    if (previousRecoverySubscription != null) {
      unawaited(
        previousRecoverySubscription.cancel(),
      );
    }

    _authSubscription = _repository.authStateChanges.listen(
      _handleAuthChange,
      onError: (_) {
        if (_isPasswordRecoveryActive) {
          return;
        }

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      },
    );

    _passwordRecoverySubscription = _repository.passwordRecoveryEvents.listen(
      (_) {
        _handlePasswordRecovery();
      },
    );

    ref.onDispose(() {
      final authSubscription = _authSubscription;

      if (authSubscription != null) {
        unawaited(
          authSubscription.cancel(),
        );
      }

      final recoverySubscription = _passwordRecoverySubscription;

      if (recoverySubscription != null) {
        unawaited(
          recoverySubscription.cancel(),
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

  void _handlePasswordRecovery() {
    _isPasswordRecoveryActive = true;

    state = state.copyWith(
      status: AuthStatus.passwordRecovery,
      clearError: true,
    );
  }

  void _handleAuthChange(User? user) {
    if (user == null) {
      if (_isPasswordRecoveryActive) {
        return;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
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

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final result = await _loginUseCase(
      email: email.trim(),
      password: password,
    );

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

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    final result = await _registerUseCase(
      email: email.trim(),
      password: password,
      displayName: displayName.trim(),
    );

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

  Future<void> signInWithGoogle() async {
    _isPasswordRecoveryActive = false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
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
        );
      },
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    final result = await _sendPasswordResetUseCase(
      email: email.trim(),
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure);
      },
      (_) {
        state = state.copyWith(clearError: true);
      },
    );
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
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
            );
          },
          (_) {
            _isPasswordRecoveryActive = false;

            state = state.copyWith(
              status: AuthStatus.unauthenticated,
              clearUser: true,
              clearError: true,
            );
          },
        );
      },
    );
  }

  Future<void> sendEmailVerification() async {
    final result = await _sendEmailVerificationUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure);
      },
      (_) {
        state = state.copyWith(clearError: true);
      },
    );
  }

  Future<void> reloadUser() async {
    final result = await _repository.reloadUser();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure);
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

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }
}
