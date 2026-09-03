import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// Handles Google authentication for DayPilot.
class GoogleSignInUseCase {
  const GoogleSignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthResult>> call() {
    return _repository.signInWithGoogle();
  }
}
