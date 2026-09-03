import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// Handles new DayPilot account registration.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthResult>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.registerWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
