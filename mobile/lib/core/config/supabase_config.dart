import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration used by DayPilot.
///
/// Only the public client key belongs in the mobile application.
/// Never place a Supabase service-role key in the client.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url =
      'https://yzmhxzwkgwyokziyetgd.supabase.co';

  static const String publishableKey =
      'sb_publishable_jU8-1rBJ3XixrV28KXCKFg_bjqEerGn';

  /// Deep link used after email verification.
  ///
  /// This exact URL must exist in:
  /// Supabase Dashboard -> Authentication -> URL Configuration
  /// -> Redirect URLs.
  static const String emailVerificationRedirectUrl =
      'com.example.daypilot://login-callback';

  /// Deep link used after password recovery.
  ///
  /// This exact URL must exist in:
  /// Supabase Dashboard -> Authentication -> URL Configuration
  /// -> Redirect URLs.
  static const String passwordRecoveryRedirectUrl =
      'com.example.daypilot://reset-password';
}

/// Provides the initialized Supabase client.
///
/// Supabase.initialize() must be completed during app startup
/// before this provider is accessed.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) {
    return Supabase.instance.client;
  },
  name: 'supabaseClientProvider',
);
