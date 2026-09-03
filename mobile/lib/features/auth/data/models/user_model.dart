import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart';

/// Data-layer representation of a DayPilot user.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.isEmailVerified,
    super.displayName,
    super.photoUrl,
    super.createdAt,
    super.lastSignInAt,
  });

  /// Creates a DayPilot user model from Supabase Auth user data.
  factory UserModel.fromSupabaseUser(supabase.User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: metadata['display_name']?.toString() ??
          metadata['full_name']?.toString(),
      photoUrl: metadata['photo_url']?.toString() ??
          metadata['avatar_url']?.toString(),
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: _parseDateTime(user.createdAt),
      lastSignInAt: _parseDateTime(user.lastSignInAt),
    );
  }

  /// Creates a user model from persisted JSON data.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      lastSignInAt: _parseDateTime(json['lastSignInAt']),
    );
  }

  /// Converts this data model into the domain entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }

  /// Converts this model into serializable JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
