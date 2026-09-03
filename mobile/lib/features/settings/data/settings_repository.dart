class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.remindersEnabled = true,
    this.aiSuggestionsEnabled = true,
    this.darkModeEnabled = false,
  });

  final bool notificationsEnabled;
  final bool remindersEnabled;
  final bool aiSuggestionsEnabled;
  final bool darkModeEnabled;

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? aiSuggestionsEnabled,
    bool? darkModeEnabled,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      aiSuggestionsEnabled: aiSuggestionsEnabled ?? this.aiSuggestionsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}

abstract class SettingsRepository {
  Future<AppSettings> getSettings();

  Future<void> saveSettings(AppSettings settings);
}

class InMemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}
