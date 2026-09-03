import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized storage service for DayPilot.
///
/// Sensitive values such as authentication tokens are stored using
/// [FlutterSecureStorage].
///
/// Non-sensitive preferences such as theme, locale, and onboarding state
/// are stored using [SharedPreferences].
class SecureStorageService {
  SecureStorageService._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static SharedPreferences? _preferences;

  /// Initializes SharedPreferences.
  ///
  /// This should normally be called during application startup.
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // Secure Storage
  // ---------------------------------------------------------------------------

  static Future<void> setSecure(
    String key,
    String value,
  ) async {
    await _secureStorage.write(
      key: key,
      value: value,
    );
  }

  static Future<String?> getSecure(String key) {
    return _secureStorage.read(key: key);
  }

  static Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // ---------------------------------------------------------------------------
  // Shared Preferences
  // ---------------------------------------------------------------------------

  static Future<void> set(
    String key,
    Object value,
  ) async {
    await _initIfNeeded();

    final preferences = _preferences!;

    if (value is String) {
      await preferences.setString(key, value);
      return;
    }

    if (value is int) {
      await preferences.setInt(key, value);
      return;
    }

    if (value is bool) {
      await preferences.setBool(key, value);
      return;
    }

    if (value is double) {
      await preferences.setDouble(key, value);
      return;
    }

    if (value is List<String>) {
      await preferences.setStringList(key, value);
      return;
    }

    throw ArgumentError(
      'Unsupported SharedPreferences value type: ${value.runtimeType}',
    );
  }

  static T? get<T>(String key) {
    final preferences = _preferences;

    if (preferences == null) {
      return null;
    }

    final value = preferences.get(key);

    if (value is T) {
      return value;
    }

    return null;
  }

  static Future<void> delete(String key) async {
    await _initIfNeeded();
    await _preferences!.remove(key);
  }

  static Future<void> clear() async {
    await _initIfNeeded();
    await _preferences!.clear();
  }

  /// Clears both secure and non-sensitive application storage.
  static Future<void> clearAll() async {
    await Future.wait([
      clearSecure(),
      clear(),
    ]);
  }

  static Future<void> _initIfNeeded() async {
    _preferences ??= await SharedPreferences.getInstance();
  }
}
