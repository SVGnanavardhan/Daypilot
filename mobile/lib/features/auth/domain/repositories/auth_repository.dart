import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../entities/user.dart';

/// Contract for all authentication operations used by DayPilot.
///
/// The domain layer depends only on this interface.
/// Concrete authentication logic is implemented in the data layer.
abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResult>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, AuthResult>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  });

  Stream<void> get passwordRecoveryEvents;

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, User?>> getCurrentUser();

  Stream<User?> get authStateChanges;

  Future<Either<Failure, User>> reloadUser();

  Future<Either<Failure, User>> updateDisplayName({
    required String displayName,
  });

  Future<Either<Failure, User>> updatePhotoUrl({
    required String photoUrl,
  });

  Future<Either<Failure, void>> deleteAccount();
}
