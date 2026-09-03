import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Updates the authenticated recovery session with a new password.
class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String newPassword,
  }) {
    return _repository.updatePassword(
      newPassword: newPassword,
    );
  }
}
