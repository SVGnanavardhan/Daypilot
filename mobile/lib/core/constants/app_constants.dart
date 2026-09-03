/// Centralized non-sensitive constants used throughout DayPilot.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // App Information
  // ---------------------------------------------------------------------------

  static const String appName = 'DayPilot';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered Student Operating System';

  // ---------------------------------------------------------------------------
  // API Configuration
  // ---------------------------------------------------------------------------

  static const String apiBaseUrl = 'https://api.daypilot.com';

  static const int apiTimeout = 30000;
  static const int apiConnectTimeout = 10000;

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ---------------------------------------------------------------------------
  // Secure Storage Keys
  // ---------------------------------------------------------------------------

  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';

  // ---------------------------------------------------------------------------
  // Preference Keys
  // ---------------------------------------------------------------------------

  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // ---------------------------------------------------------------------------
  // Date & Time Formats
  // ---------------------------------------------------------------------------

  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';

  static const String timeFormatDisplay = 'hh:mm a';
  static const String timeFormatApi = 'HH:mm';

  static const String dateTimeFormatDisplay = 'MMM dd, yyyy hh:mm a';
  static const String dateTimeFormatApi = 'yyyy-MM-dd HH:mm';

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  static const int maxUsernameLength = 50;
  static const int maxBioLength = 500;

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusLarge = 16;
  static const double borderRadiusXLarge = 24;

  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;

  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  static const int syncRetryLimit = 3;
  static const int syncBatchSize = 50;
}
