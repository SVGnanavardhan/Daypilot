import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Handles email-verification requests for the current DayPilot user.
class SendEmailVerificationUseCase {
  const SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.sendEmailVerification();
  }
}
