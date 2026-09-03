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
    unawaited(
      loadSettings(),
    );
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

  // ignore: avoid_positional_boolean_parameters
  Future<void> setNotificationsEnabled(bool value) {
    return _save(
      state.settings.copyWith(
        notificationsEnabled: value,
      ),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setRemindersEnabled(bool value) {
    return _save(
      state.settings.copyWith(
        remindersEnabled: value,
      ),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAiSuggestionsEnabled(bool value) {
    return _save(
      state.settings.copyWith(
        aiSuggestionsEnabled: value,
      ),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDarkModeEnabled(bool value) {
    return _save(
      state.settings.copyWith(
        darkModeEnabled: value,
      ),
    );
  }

  Future<void> _save(AppSettings settings) async {
    state = state.copyWith(
      settings: settings,
      clearError: true,
    );

    try {
      await _repository.saveSettings(settings);
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
      );
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => InMemorySettingsRepository(),
);

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(
    repository: ref.watch(
      settingsRepositoryProvider,
    ),
  ),
);
