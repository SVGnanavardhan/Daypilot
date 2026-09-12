import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../../../core/sync/sync_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;
  bool _isLoggingOut = false;

  bool get _isBusy => _isSyncing || _isLoggingOut;

  Future<void> _syncNow() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      await ref.read(syncServiceProvider).syncNow();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    await ref.read(authProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    if (authState.error != null) {
      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.error!.message,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      ref.read(authProvider.notifier).clearError();

      return;
    }

    context.go('/login');
  }

  Future<void> _setSoundsEnabled(
    bool value,
  ) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .setSoundsEnabled(
          value: value,
        );

    if (!mounted) {
      return;
    }

    _showSettingsErrorIfNeeded();
  }

  Future<void> _setHapticsEnabled(
    bool value,
  ) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .setHapticsEnabled(
          value: value,
        );

    if (!mounted) {
      return;
    }

    _showSettingsErrorIfNeeded();
  }

  Future<void> _setLanguage(
    String value,
  ) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .setLanguage(
          value: value,
        );

    if (!mounted) {
      return;
    }

    _showSettingsErrorIfNeeded();

    final error = ref.read(settingsControllerProvider).error;

    if (error != null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value == 'English'
              ? 'Language set to English.'
              : '$value saved. Full translation will be enabled in a future version.',
        ),
      ),
    );
  }

  void _showSettingsErrorIfNeeded() {
    final settingsState = ref.read(settingsControllerProvider);

    final error = settingsState.error;

    if (error == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to save preference: $error',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );

    ref.read(settingsControllerProvider.notifier).clearError();
  }

  void _showThemeSheet() {
    final currentTheme = ref.read(appThemeModeProvider);

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text(
                      'Choose Appearance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RadioGroup<ThemeDataMode>(
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      ref
                          .read(
                            appThemeModeProvider.notifier,
                          )
                          .setThemeMode(value);

                      Navigator.of(
                        sheetContext,
                      ).pop();
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeDataMode>(
                          value: ThemeDataMode.system,
                          title: Text('System'),
                          secondary: Icon(
                            Icons.settings_suggest_outlined,
                          ),
                        ),
                        RadioListTile<ThemeDataMode>(
                          value: ThemeDataMode.light,
                          title: Text('Light'),
                          secondary: Icon(
                            Icons.light_mode_outlined,
                          ),
                        ),
                        RadioListTile<ThemeDataMode>(
                          value: ThemeDataMode.dark,
                          title: Text('Dark'),
                          secondary: Icon(
                            Icons.dark_mode_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLanguageSheet(
    String currentLanguage,
  ) {
    const languages = <String>[
      'English',
      'Telugu',
      'Hindi',
    ];

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text(
                      'App Language',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'English is fully supported in V1.',
                    ),
                  ),
                  RadioGroup<String>(
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      Navigator.of(
                        sheetContext,
                      ).pop();

                      unawaited(
                        _setLanguage(value),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: languages
                          .map(
                            (language) => RadioListTile<String>(
                              value: language,
                              title: Text(language),
                              secondary: const Icon(
                                Icons.language_rounded,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _themeLabel(
    ThemeDataMode mode,
  ) {
    switch (mode) {
      case ThemeDataMode.light:
        return 'Light';

      case ThemeDataMode.dark:
        return 'Dark';

      case ThemeDataMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);

    final settingsState = ref.watch(settingsControllerProvider);

    final settings = settingsState.settings;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (settingsState.isLoading)
            const Padding(
              padding: EdgeInsets.only(
                right: 8,
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _isBusy ? null : _logout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                  ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref
                .read(
                  settingsControllerProvider.notifier,
                )
                .loadSettings();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              48,
            ),
            children: [
              if (settingsState.error != null) ...[
                Card(
                  color: colorScheme.errorContainer,
                  child: ListTile(
                    leading: Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.onErrorContainer,
                    ),
                    title: Text(
                      'Unable to load settings',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    subtitle: Text(
                      settingsState.error!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: 'Retry',
                      onPressed: () {
                        unawaited(
                          ref
                              .read(
                                settingsControllerProvider.notifier,
                              )
                              .loadSettings(),
                        );
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const _SettingsSectionTitle(
                title: 'App Preferences',
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.notifications_outlined,
                      ),
                      title: const Text(
                        'Notifications',
                      ),
                      subtitle: const Text(
                        'Manage reminders and alerts',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: _isBusy
                          ? null
                          : () {
                              unawaited(
                                context.push(
                                  '/notifications',
                                ),
                              );
                            },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        settings.soundsEnabled
                            ? Icons.volume_up_outlined
                            : Icons.volume_off_outlined,
                      ),
                      title: const Text(
                        'App Sounds',
                      ),
                      subtitle: const Text(
                        'Play sounds for alerts and actions',
                      ),
                      value: settings.soundsEnabled,
                      onChanged: _isBusy || settingsState.isLoading
                          ? null
                          : (value) {
                              unawaited(
                                _setSoundsEnabled(
                                  value,
                                ),
                              );
                            },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        settings.hapticsEnabled
                            ? Icons.vibration_rounded
                            : Icons.phone_android_outlined,
                      ),
                      title: const Text(
                        'Haptic Feedback',
                      ),
                      subtitle: const Text(
                        'Use vibration for supported interactions',
                      ),
                      value: settings.hapticsEnabled,
                      onChanged: _isBusy || settingsState.isLoading
                          ? null
                          : (value) {
                              unawaited(
                                _setHapticsEnabled(
                                  value,
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SettingsSectionTitle(
                title: 'Display & Language',
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.palette_outlined,
                      ),
                      title: const Text(
                        'Appearance',
                      ),
                      subtitle: Text(
                        _themeLabel(themeMode),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: _isBusy ? null : _showThemeSheet,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.language_rounded,
                      ),
                      title: const Text(
                        'Language',
                      ),
                      subtitle: Text(
                        settings.language,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: _isBusy || settingsState.isLoading
                          ? null
                          : () {
                              _showLanguageSheet(
                                settings.language,
                              );
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SettingsSectionTitle(
                title: 'Data & Sync',
              ),
              Card(
                child: ListTile(
                  leading: _isSyncing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.sync_rounded,
                        ),
                  title: const Text(
                    'Sync Now',
                  ),
                  subtitle: Text(
                    _isSyncing
                        ? 'Synchronizing DayPilot data...'
                        : 'Synchronize local and cloud data',
                  ),
                  trailing: _isSyncing
                      ? null
                      : const Icon(
                          Icons.chevron_right_rounded,
                        ),
                  onTap: _isBusy ? null : _syncNow,
                ),
              ),
              const SizedBox(height: 20),
              const _SettingsSectionTitle(
                title: 'About',
              ),
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                      ),
                      title: Text(
                        'DayPilot',
                      ),
                      subtitle: Text(
                        'Version 1',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.privacy_tip_outlined,
                      ),
                      title: const Text(
                        'Privacy & Data',
                      ),
                      subtitle: const Text(
                        'Your account data remains separated per user',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Detailed Privacy & Data controls are planned for a future version.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: _isBusy ? null : _logout,
                icon: _isLoggingOut
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.error,
                        ),
                      )
                    : Icon(
                        Icons.logout_rounded,
                        color: colorScheme.error,
                      ),
                label: Text(
                  _isLoggingOut
                      ? 'Logging out...'
                      : 'Logout',
                  style: TextStyle(
                    color: colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        4,
        0,
        4,
        8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
