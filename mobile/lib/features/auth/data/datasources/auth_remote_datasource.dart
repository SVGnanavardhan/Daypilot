import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart';

/// Remote authentication data source backed by Supabase Auth.
///
/// This class is responsible only for direct communication with Supabase.
/// Domain-level mapping is handled by the repository layer.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    SupabaseClient? supabaseClient,
  }) : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to sign in. Please try again.',
        code: 'SIGN_IN_FAILED',
        originalError: error,
      );
    }
  }

  Future<AuthResponse> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: SupabaseConfig.emailVerificationRedirectUrl,
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to create account. Please try again.',
        code: 'REGISTRATION_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to sign out. Please try again.',
        code: 'SIGN_OUT_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: SupabaseConfig.passwordRecoveryRedirectUrl,
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to send password reset email.',
        code: 'PASSWORD_RESET_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final value = newPassword.trim();

    if (value.length < 8) {
      throw const ValidationException(
        message: 'Password must contain at least 8 characters.',
        code: 'PASSWORD_TOO_SHORT',
      );
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: value,
        ),
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to update your password. Please try again.',
        code: 'PASSWORD_UPDATE_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> sendEmailVerification() async {
    final email = _supabase.auth.currentUser?.email;

    if (email == null || email.trim().isEmpty) {
      throw const AppAuthException(
        message: 'No authenticated user was found.',
        code: 'NO_USER',
      );
    }

    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: SupabaseConfig.emailVerificationRedirectUrl,
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to resend verification email.',
        code: 'EMAIL_VERIFICATION_FAILED',
        originalError: error,
      );
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map(
      (authState) => authState.session?.user,
    );
  }

  Stream<void> get passwordRecoveryEvents {
    return _supabase.auth.onAuthStateChange
        .where(
          (authState) =>
              authState.event == AuthChangeEvent.passwordRecovery,
        )
        .map((_) {});
  }

  Future<User> reloadUser() async {
    try {
      final response = await _supabase.auth.getUser();
      final user = response.user;

      if (user == null) {
        throw const AppAuthException(
          message: 'No authenticated user was found.',
          code: 'NO_USER',
        );
      }

      return user;
    } on AppAuthException {
      rethrow;
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to refresh user information.',
        code: 'USER_RELOAD_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final value = displayName.trim();

    if (value.isEmpty) {
      throw const ValidationException(
        message: 'Display name cannot be empty.',
        code: 'INVALID_DISPLAY_NAME',
      );
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': value,
          },
        ),
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to update display name.',
        code: 'DISPLAY_NAME_UPDATE_FAILED',
        originalError: error,
      );
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    final value = photoUrl.trim();

    if (value.isEmpty) {
      throw const ValidationException(
        message: 'Photo URL cannot be empty.',
        code: 'INVALID_PHOTO_URL',
      );
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'photo_url': value,
          },
        ),
      );
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to update profile photo.',
        code: 'PHOTO_UPDATE_FAILED',
        originalError: error,
      );
    }
  }

  /// Account deletion must never be performed directly from the mobile app.
  ///
  /// It will later be connected to a secure Supabase Edge Function.
  Future<void> deleteAccount() async {
    throw const AppAuthException(
      message: 'Account deletion requires a secure backend function.',
      code: 'DELETE_REQUIRES_BACKEND',
    );
  }

  AppAuthException _handleSupabaseAuthException(
    AuthException error,
  ) {
    final message = error.message;
    final normalizedMessage = message.toLowerCase();

    if (normalizedMessage.contains('invalid login credentials')) {
      return AppAuthException(
        message: 'Incorrect email or password.',
        code: 'INVALID_CREDENTIAL',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('already registered') ||
        normalizedMessage.contains('already been registered')) {
      return AppAuthException(
        message: 'An account already exists with this email.',
        code: 'EMAIL_ALREADY_IN_USE',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('email not confirmed')) {
      return AppAuthException(
        message: 'Please verify your email before signing in.',
        code: 'EMAIL_NOT_VERIFIED',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('rate limit') ||
        normalizedMessage.contains('too many requests')) {
      return AppAuthException(
        message: 'Too many attempts. Please try again later.',
        code: 'RATE_LIMITED',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('same password')) {
      return AppAuthException(
        message:
            'Please choose a password different from your old password.',
        code: 'SAME_PASSWORD',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('password')) {
      return AppAuthException(
        message: message,
        code: 'AUTH_PASSWORD_ERROR',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('email')) {
      return AppAuthException(
        message: message,
        code: 'AUTH_EMAIL_ERROR',
        originalError: error,
      );
    }

    return AppAuthException(
      message: 'Authentication failed. Please try again.',
      code: 'SUPABASE_AUTH_ERROR',
      originalError: error,
    );
  }
}