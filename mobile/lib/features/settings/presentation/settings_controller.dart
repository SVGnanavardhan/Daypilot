import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

class SettingsState {
  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoading = false,
    this.error,
  });

  final AppSettings settings;
  final bool isLoading;
  final String? error;

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController({
    required SettingsRepository repository,
  })  : _repository = repository,
        super(const SettingsState()) {
    unawaited(loadSettings());
  }

  final SettingsRepository _repository;

  Future<void> loadSettings() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final settings = await _repository.getSettings();

      state = state.copyWith(
        settings: settings,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> setNotificationsEnabled({
    required bool value,
  }) {
    return _save(
      state.settings.copyWith(
        notificationsEnabled: value,
      ),
    );
  }

  Future<void> setRemindersEnabled({
    required bool value,
  }) {
    return _save(
      state.settings.copyWith(
        remindersEnabled: value,
      ),
    );
  }

  Future<void> setAiSuggestionsEnabled({
    required bool value,
  }) {
    return _save(
      state.settings.copyWith(
        aiSuggestionsEnabled: value,
      ),
    );
  }

  Future<void> setDarkModeEnabled({
    required bool value,
  }) {
    return _save(
      state.settings.copyWith(
        darkModeEnabled: value,
      ),
    );
  }

  Future<void> setSoundsEnabled({
    required bool value,
  }) {
    return _save(
      state.settings.copyWith(
        soundsEnabled: value,
      ),
    );
  }

  Future<void> setHapticsEnabled({
    required bool value,
  }) {
    return _save(
      state.settings.copyWith(
        hapticsEnabled: value,
      ),
    );
  }

  Future<void> setLanguage({
    required String value,
  }) {
    return _save(
      state.settings.copyWith(
        language: value,
      ),
    );
  }

  Future<void> _save(
    AppSettings settings,
  ) async {
    final previousSettings = state.settings;

    state = state.copyWith(
      settings: settings,
      clearError: true,
    );

    try {
      await _repository.saveSettings(
        settings,
      );
    } catch (error) {
      state = state.copyWith(
        settings: previousSettings,
        error: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) {
    return SharedPreferencesSettingsRepository();
  },
);

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) {
    return SettingsController(
      repository: ref.watch(settingsRepositoryProvider),
    );
  },
);
