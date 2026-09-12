import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.remindersEnabled = true,
    this.aiSuggestionsEnabled = true,
    this.darkModeEnabled = false,
    this.soundsEnabled = true,
    this.hapticsEnabled = true,
    this.language = 'English',
  });

  final bool notificationsEnabled;
  final bool remindersEnabled;
  final bool aiSuggestionsEnabled;
  final bool darkModeEnabled;

  final bool soundsEnabled;
  final bool hapticsEnabled;

  final String language;

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? aiSuggestionsEnabled,
    bool? darkModeEnabled,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    String? language,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      aiSuggestionsEnabled: aiSuggestionsEnabled ?? this.aiSuggestionsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      language: language ?? this.language,
    );
  }
}

abstract class SettingsRepository {
  Future<AppSettings> getSettings();

  Future<void> saveSettings(
    AppSettings settings,
  );
}

class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const String _notificationsKey = 'settings_notifications_enabled';

  static const String _remindersKey = 'settings_reminders_enabled';

  static const String _aiSuggestionsKey = 'settings_ai_suggestions_enabled';

  static const String _darkModeKey = 'settings_dark_mode_enabled';

  static const String _soundsKey = 'settings_sounds_enabled';

  static const String _hapticsKey = 'settings_haptics_enabled';

  static const String _languageKey = 'settings_language';

  @override
  Future<AppSettings> getSettings() async {
    final preferences = await SharedPreferences.getInstance();

    return AppSettings(
      notificationsEnabled: preferences.getBool(_notificationsKey) ?? true,
      remindersEnabled: preferences.getBool(_remindersKey) ?? true,
      aiSuggestionsEnabled: preferences.getBool(_aiSuggestionsKey) ?? true,
      darkModeEnabled: preferences.getBool(_darkModeKey) ?? false,
      soundsEnabled: preferences.getBool(_soundsKey) ?? true,
      hapticsEnabled: preferences.getBool(_hapticsKey) ?? true,
      language: preferences.getString(_languageKey) ?? 'English',
    );
  }

  @override
  Future<void> saveSettings(
    AppSettings settings,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.setBool(
        _notificationsKey,
        settings.notificationsEnabled,
      ),
      preferences.setBool(
        _remindersKey,
        settings.remindersEnabled,
      ),
      preferences.setBool(
        _aiSuggestionsKey,
        settings.aiSuggestionsEnabled,
      ),
      preferences.setBool(
        _darkModeKey,
        settings.darkModeEnabled,
      ),
      preferences.setBool(
        _soundsKey,
        settings.soundsEnabled,
      ),
      preferences.setBool(
        _hapticsKey,
        settings.hapticsEnabled,
      ),
      preferences.setString(
        _languageKey,
        settings.language,
      ),
    ]);
  }
}
