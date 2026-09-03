import 'package:equatable/equatable.dart';

import 'user.dart';

/// Domain result returned after a successful authentication operation.
class AuthResult extends Equatable {
  const AuthResult({
    required this.user,
    required this.isNewUser,
  });

  final User user;

  /// Indicates whether the authenticated user has just created
  /// a new DayPilot account.
  final bool isNewUser;

  @override
  List<Object?> get props => [
        user,
        isNewUser,
      ];
}
