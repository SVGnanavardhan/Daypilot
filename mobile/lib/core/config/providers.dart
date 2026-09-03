import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Supported application theme modes.
enum ThemeDataMode {
  light,
  dark,
  system,
}

/// Controls the application's theme mode.
///
/// This provider is kept alive because theme state is required
/// throughout the entire application lifecycle.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeDataMode build() {
    return ThemeDataMode.system;
  }

  void setThemeMode(ThemeDataMode mode) {
    if (state == mode) {
      return;
    }

    state = mode;
  }
}

/// Controls the application's active locale.
///
/// English is currently the default language.
/// Additional DayPilot languages can be added later without
/// changing consumers of this provider.
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  @override
  Locale build() {
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    if (state == locale) {
      return;
    }

    state = locale;
  }
}
