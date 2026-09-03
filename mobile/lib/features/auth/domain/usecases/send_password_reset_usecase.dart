import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Handles password-reset email requests for DayPilot users.
class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String email,
  }) {
    return _repository.sendPasswordResetEmail(
      email: email,
    );
  }
}
