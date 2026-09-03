import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Supabase-backed implementation of the authentication repository.
///
/// This layer converts remote authentication responses into
/// DayPilot domain entities and failures.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, AuthResult>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final supabaseUser = response.user;

      if (supabaseUser == null) {
        throw const AppAuthException(
          message: 'Authentication failed.',
          code: 'NO_USER',
        );
      }

      final user = UserModel.fromSupabaseUser(supabaseUser);

      await _storeSession(user);

      return Right(
        AuthResult(
          user: user,
          isNewUser: false,
        ),
      );
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);

      return const Left(
        UnknownFailure(
          message: 'Unable to sign in. Please try again.',
          code: 'SIGN_IN_UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResult>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await remoteDataSource.registerWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final supabaseUser = response.user;

      if (supabaseUser == null) {
        throw const AppAuthException(
          message: 'Registration failed.',
          code: 'NO_USER',
        );
      }

      if (response.session != null) {
        await remoteDataSource.updateDisplayName(
          displayName.trim(),
        );
      }

      final refreshedUser = response.session != null
          ? await remoteDataSource.reloadUser()
          : supabaseUser;

      final user = UserModel.fromSupabaseUser(refreshedUser);

      await _storeSession(user);

      return Right(
        AuthResult(
          user: user,
          isNewUser: true,
        ),
      );
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);

      return const Left(
        UnknownFailure(
          message: 'Unable to create account. Please try again.',
          code: 'REGISTRATION_UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithGoogle() async {
    return const Left(
      AuthFailure(
        message: 'Google sign-in is not configured yet.',
        code: 'GOOGLE_SIGN_IN_NOT_CONFIGURED',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();

      await _clearSession();

      return const Right(null);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);

      return const Left(
        UnknownFailure(
          message: 'Unable to sign out. Please try again.',
          code: 'SIGN_OUT_UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(
        email.trim(),
      );

      return const Right(null);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);

      return const Left(
        UnknownFailure(
          message: 'Unable to send password reset email.',
          code: 'PASSWORD_RESET_UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(
        newPassword,
      );

      return const Right(null);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);

      return const Left(
        UnknownFailure(
          message: 'Unable to update your password. Please try again.',
          code: 'PASSWORD_UPDATE_UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Stream<void> get passwordRecoveryEvents {
    return remoteDataSource.passwordRecoveryEvents;
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();

      return const Right(null);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final supabaseUser = remoteDataSource.getCurrentUser();

      if (supabaseUser == null) {
        return const Right(null);
      }

      final user = UserModel.fromSupabaseUser(supabaseUser);

      await _storeSession(user);

      return Right(user);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);

      return const Left(
        UnknownFailure(
          message: 'Unable to restore your session.',
          code: 'GET_CURRENT_USER_ERROR',
        ),
      );
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (supabaseUser) {
        if (supabaseUser == null) {
          return null;
        }

        return UserModel.fromSupabaseUser(supabaseUser);
      },
    );
  }

  @override
  Future<Either<Failure, User>> reloadUser() async {
    try {
      final supabaseUser = await remoteDataSource.reloadUser();

      final user = UserModel.fromSupabaseUser(supabaseUser);

      await _storeSession(user);

      return Right(user);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateDisplayName({
    required String displayName,
  }) async {
    try {
      await remoteDataSource.updateDisplayName(
        displayName.trim(),
      );

      final supabaseUser = await remoteDataSource.reloadUser();

      final user = UserModel.fromSupabaseUser(supabaseUser);

      await _storeSession(user);

      return Right(user);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updatePhotoUrl({
    required String photoUrl,
  }) async {
    try {
      await remoteDataSource.updatePhotoUrl(
        photoUrl.trim(),
      );

      final supabaseUser = await remoteDataSource.reloadUser();

      final user = UserModel.fromSupabaseUser(supabaseUser);

      await _storeSession(user);

      return Right(user);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();

      await _clearSession();

      return const Right(null);
    } on AppException catch (error) {
      return Left(
        ErrorHandler.handleException(error),
      );
    }
  }

  Future<void> _storeSession(User user) async {
    await Future.wait([
      SecureStorageService.setSecure(
        AppConstants.keyUserId,
        user.id,
      ),
      SecureStorageService.setSecure(
        'user_email',
        user.email,
      ),
    ]);
  }

  Future<void> _clearSession() async {
    await Future.wait([
      SecureStorageService.deleteSecure(
        AppConstants.keyUserId,
      ),
      SecureStorageService.deleteSecure(
        AppConstants.keyAuthToken,
      ),
      SecureStorageService.deleteSecure(
        AppConstants.keyRefreshToken,
      ),
      SecureStorageService.deleteSecure(
        'user_email',
      ),
    ]);
  }
}
