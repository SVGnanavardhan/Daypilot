import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';

/// Remote authentication data source backed by Supabase Auth.
///
/// DayPilot V1 uses in-app 8-digit email OTP verification for:
/// - New account email verification
/// - Forgot-password recovery
///
/// Email delivery is handled by Supabase Auth through the configured SMTP
/// provider. The OTP itself is entered and verified directly inside DayPilot.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    SupabaseClient? supabaseClient,
  }) : _supabase = supabaseClient ?? Supabase.instance.client;

  static const int _otpLength = 8;

  final SupabaseClient _supabase;

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw const ValidationException(
        message: 'Email is required.',
        code: 'EMAIL_REQUIRED',
      );
    }

    if (password.isEmpty) {
      throw const ValidationException(
        message: 'Password is required.',
        code: 'PASSWORD_REQUIRED',
      );
    }

    try {
      // Always validate the credentials currently entered on the login screen.
      // Clear an old active session first so a stale session cannot be treated
      // as a successful fresh login.
      if (_supabase.auth.currentSession != null) {
        await _supabase.auth.signOut();
      }

      final response = await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user == null || session == null) {
        throw const AppAuthException(
          message: 'Unable to verify your login credentials.',
          code: 'INVALID_LOGIN_RESPONSE',
        );
      }

      return response;
    } on ValidationException {
      rethrow;
    } on AppAuthException {
      rethrow;
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
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw const ValidationException(
        message: 'Email is required.',
        code: 'EMAIL_REQUIRED',
      );
    }

    if (password.isEmpty) {
      throw const ValidationException(
        message: 'Password is required.',
        code: 'PASSWORD_REQUIRED',
      );
    }

    try {
      // Supabase sends the Confirm signup email.
      //
      // The configured template exposes {{ .Token }}, which is entered
      // directly inside DayPilot instead of using a browser redirect.
      return await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
      );
    } on ValidationException {
      rethrow;
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

  /// Verifies the 8-digit OTP sent after account registration.
  ///
  /// A successful verification creates an authenticated Supabase session.
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedToken = token.trim();

    if (normalizedEmail.isEmpty) {
      throw const ValidationException(
        message: 'Email is required.',
        code: 'EMAIL_REQUIRED',
      );
    }

    if (normalizedToken.isEmpty) {
      throw const ValidationException(
        message: 'Verification code is required.',
        code: 'OTP_REQUIRED',
      );
    }

    if (!_isValidOtp(normalizedToken)) {
      throw const ValidationException(
        message: 'Enter the 8-digit verification code.',
        code: 'INVALID_OTP_FORMAT',
      );
    }

    try {
      final response = await _supabase.auth.verifyOTP(
        email: normalizedEmail,
        token: normalizedToken,
        type: OtpType.signup,
      );

      if (response.user == null || response.session == null) {
        throw const AppAuthException(
          message: 'Unable to verify the email code.',
          code: 'INVALID_EMAIL_OTP_RESPONSE',
        );
      }

      return response;
    } on ValidationException {
      rethrow;
    } on AppAuthException {
      rethrow;
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to verify the email code. Please try again.',
        code: 'EMAIL_OTP_VERIFICATION_FAILED',
        originalError: error,
      );
    }
  }

  /// Resends the account-verification OTP.
  Future<void> resendEmailVerificationOtp({
    required String email,
  }) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw const ValidationException(
        message: 'Email is required.',
        code: 'EMAIL_REQUIRED',
      );
    }

    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: normalizedEmail,
      );
    } on ValidationException {
      rethrow;
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to resend verification code.',
        code: 'EMAIL_VERIFICATION_RESEND_FAILED',
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

  /// Sends the forgot-password recovery OTP.
  ///
  /// Supabase sends the Reset password email template. The template exposes
  /// {{ .Token }}, so no browser redirect is required for the V1 flow.
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw const ValidationException(
        message: 'Email is required.',
        code: 'EMAIL_REQUIRED',
      );
    }

    try {
      await _supabase.auth.resetPasswordForEmail(
        normalizedEmail,
      );
    } on ValidationException {
      rethrow;
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to send password reset code.',
        code: 'PASSWORD_RESET_FAILED',
        originalError: error,
      );
    }
  }

  /// Verifies the 8-digit forgot-password recovery OTP.
  ///
  /// On success Supabase creates a temporary recovery session that is used by
  /// [updatePassword] to set the user's new password.
  Future<AuthResponse> verifyPasswordRecoveryOtp({
    required String email,
    required String token,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedToken = token.trim();

    if (normalizedEmail.isEmpty) {
      throw const ValidationException(
        message: 'Email is required.',
        code: 'EMAIL_REQUIRED',
      );
    }

    if (normalizedToken.isEmpty) {
      throw const ValidationException(
        message: 'Verification code is required.',
        code: 'OTP_REQUIRED',
      );
    }

    if (!_isValidOtp(normalizedToken)) {
      throw const ValidationException(
        message: 'Enter the 8-digit verification code.',
        code: 'INVALID_OTP_FORMAT',
      );
    }

    try {
      final response = await _supabase.auth.verifyOTP(
        email: normalizedEmail,
        token: normalizedToken,
        type: OtpType.recovery,
      );

      if (response.user == null || response.session == null) {
        throw const AppAuthException(
          message: 'Unable to verify the recovery code.',
          code: 'INVALID_RECOVERY_OTP_RESPONSE',
        );
      }

      return response;
    } on ValidationException {
      rethrow;
    } on AppAuthException {
      rethrow;
    } on AuthException catch (error) {
      throw _handleSupabaseAuthException(error);
    } catch (error) {
      throw AppAuthException(
        message: 'Unable to verify the recovery code. Please try again.',
        code: 'RECOVERY_OTP_VERIFICATION_FAILED',
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

    if (!RegExp('[A-Za-z]').hasMatch(value)) {
      throw const ValidationException(
        message: 'Password must contain at least one letter.',
        code: 'PASSWORD_LETTER_REQUIRED',
      );
    }

    if (!RegExp('[0-9]').hasMatch(value)) {
      throw const ValidationException(
        message: 'Password must contain at least one number.',
        code: 'PASSWORD_NUMBER_REQUIRED',
      );
    }

    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          password: value,
        ),
      );

      if (response.user == null) {
        throw const AppAuthException(
          message: 'Unable to update your password.',
          code: 'INVALID_PASSWORD_UPDATE_RESPONSE',
        );
      }
    } on ValidationException {
      rethrow;
    } on AppAuthException {
      rethrow;
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

  /// Compatibility method for older repository/use-case code.
  Future<void> sendEmailVerification() async {
    final email = _supabase.auth.currentUser?.email;

    if (email == null || email.trim().isEmpty) {
      throw const AppAuthException(
        message: 'No authenticated user was found.',
        code: 'NO_USER',
      );
    }

    await resendEmailVerificationOtp(
      email: email,
    );
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map(
      (authState) => authState.session?.user,
    );
  }

  /// Retained for compatibility with the existing repository.
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
    } on ValidationException {
      rethrow;
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
    } on ValidationException {
      rethrow;
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

  bool _isValidOtp(String token) {
    return RegExp('^\\d{$_otpLength}\$').hasMatch(token);
  }

  AppAuthException _handleSupabaseAuthException(
    AuthException error,
  ) {
    final message = error.message;
    final normalizedMessage = message.toLowerCase();

    if (normalizedMessage.contains('invalid login credentials') ||
        normalizedMessage.contains('invalid credentials')) {
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
        normalizedMessage.contains('too many requests') ||
        normalizedMessage.contains('email rate limit')) {
      return AppAuthException(
        message: 'Too many attempts. Please try again later.',
        code: 'RATE_LIMITED',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('token has expired') ||
        normalizedMessage.contains('otp expired') ||
        normalizedMessage.contains('expired')) {
      return AppAuthException(
        message: 'This verification code has expired. Request a new code.',
        code: 'OTP_EXPIRED',
        originalError: error,
      );
    }

    if (normalizedMessage.contains('invalid token') ||
        normalizedMessage.contains('invalid otp') ||
        normalizedMessage.contains('token is invalid')) {
      return AppAuthException(
        message: 'Incorrect verification code. Please try again.',
        code: 'INVALID_OTP',
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
