import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated DayPilot user.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.lastSignInAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool clearDisplayName = false,
    bool clearPhotoUrl = false,
    bool clearCreatedAt = false,
    bool clearLastSignInAt = false,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: clearDisplayName ? null : displayName ?? this.displayName,
      photoUrl: clearPhotoUrl ? null : photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: clearCreatedAt ? null : createdAt ?? this.createdAt,
      lastSignInAt:
          clearLastSignInAt ? null : lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        isEmailVerified,
        createdAt,
        lastSignInAt,
      ];
}
